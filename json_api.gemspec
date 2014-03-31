Gem::Specification.new do |s|
  s.name        = 'json_api'
  s.version     = '0.0.0'
  s.date        = '2014-03-30'
  s.summary     = 'Sinatra JSON API Framework Classes'
  s.description = "A set of classes to simplify JSON APIs"
  s.authors     = ["Tom Cully"]
  s.email       = 'tomhughcully@gmail.com'
  s.files       = [
    "lib/json_api.rb",
    "lib/json_api/service.rb",
    "lib/json_api/crud.rb",
    "lib/json_api/sinatra_api.rb"
    "lib/json_api/auth_client.rb"
  ]
  s.homepage    =
    'http://rubygems.org/gems/json_api'
  s.license       = 'MIT'
end