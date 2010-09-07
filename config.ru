require "twitter"

use Rack::Static, :urls => ["/assets"]

run lambda { |env|

  members = %w(floehopper chrisroos lazyatom jasoncale tomafro kalv)
  in_office = %w(floehopper chrisroos lazyatom jasoncale)

  # pathetically simple cache
  @beardiness = {}

  def weighting_for_person(person)
    unless @beardiness[person]
      if latest_tweet = Twitter::Search.new("#shaved OR #trimmed OR #has_a_beard").from(person).fetch.results.first
        days_since_tweet = (Time.now - Time.parse(latest_tweet.created_at)) / (60*60)
        @beardiness[person] = if latest_tweet.text =~ /#has_a_beard/
          1
        elsif latest_tweet.text =~ /#trimmed/
          [1, (days_since_tweet / 10) + 0.1].max
        else
          [1, (days_since_tweet / 10)].max
        end
      else
        @beardiness[person] = 0.2 # guess
      end
    end
    @beardiness[person]
  end

  def beard_ratio(people)
    people.map { |m| weighting_for_person(m) }.inject(0) {|a,b| a + b }
  end

  body = File.read('index.html').gsub(/\[OVERALL_RATIO\]/, "#{beard_ratio(members)}/#{members.length}")
  body.gsub!(/\[OFFICE_RATIO\]/, "#{beard_ratio(in_office)}/#{in_office.length}")

  [
    200,
    {'Content-Type'=>'text/html', "Content-Length" => body.length.to_s, 'Cache-Control' => 'public, max-age=600'},
    body
  ]
}


