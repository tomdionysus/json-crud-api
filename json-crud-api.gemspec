Gem::Specification.new do |s|
  s.name        = 'json-crud-api'
  s.version     = '0.0.6'
  s.date        = '2014-05-06'
  s.summary     = 'Sinatra JSON API Framework Classes'
  s.description = "A set of classes to simplify JSON APIs"
  s.authors     = ["Tom Cully"]
  s.email       = 'tomhughcully@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb')
  s.test_files  = Dir.glob('spec/**/*.rb')
  s.homepage    = 'http://rubygems.org/gems/json-crud-api'
  s.license     = 'MIT'
  s.required_ruby_version = '>= 2.0.0'
  s.add_development_dependency "simplecov"
  s.add_development_dependency "dotenv"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-mocks"
  s.add_development_dependency "rack-test"
  s.add_development_dependency "codeclimate-test-reporter"
  s.add_runtime_dependency 'dalli', '~> 2.6.4', '>= 2.6.4'
  s.add_runtime_dependency 'json', '~> 1.8.0', '>= 1.8.0'
  s.add_runtime_dependency 'mysql2', '~> 0.3.13', '>= 0.3.13'
  s.add_runtime_dependency 'sinatra', '~> 1.4.3', '>= 1.4.3'
  s.add_runtime_dependency 'datamapper', '~> 1.2.0', '>= 1.2.0'
end
