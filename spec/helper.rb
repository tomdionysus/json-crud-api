require "coveralls"
Coveralls.wear!
SimpleCov.coverage_dir('spec/coverage')

require "dotenv"
Dotenv.load

require "json-crud-api"

RSpec.configure do |c|
  c.include Helpers
end
