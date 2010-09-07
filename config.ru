use Rack::Static, :urls => ["/assets"]

run lambda { |env|   
  
  james_m = :beard
  chris = :beard
  james_a = :stubble
  jase = :clean
  tom = :stubble
  kalv = :beard

  members = [james_m, chris, james_a, jase, tom, kalv]
  in_office = [james_m, chris, james_a, jase]

  def beard_ratio(people)
    weightings = {
      :beard => 1,
      :stubble => 0.5,
      :clean => 0
    }
    people.length / people.map { |m| weightings[m] }.inject(0) {|a,b| a + b } 
  end

  body = File.read('index.html').gsub(/\[OVERALL_RATIO\]/, "1 : #{beard_ratio(members)}")
  body.gsub!(/\[OFFICE_RATIO\]/, "1 : #{beard_ratio(in_office)}")
  
  [
    200, 
    {'Content-Type'=>'text/html', "Content-Length" => body.length.to_s, 'Cache-Control' => 'public, max-age=600'}, 
    body
  ] 
}


