require "codeclimate-test-reporter"
CodeClimate::TestReporter.start

require 'simplecov'
require 'rack/test'

require "dotenv"
Dotenv.load

SimpleCov.start do
  coverage_dir "spec/coverage"
end


require "json-crud-api"

RSpec.configure do |c|
  c.include Helpers
end
