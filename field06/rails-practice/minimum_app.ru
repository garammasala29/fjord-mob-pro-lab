App = lambda do |env|
  [200, { "Content-Type" => "text/html"}, ["Hello world!"]]
end
run App
