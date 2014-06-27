require "helper"

describe JsonCrudApi::API do
  include Rack::Test::Methods

  def app
    JsonCrudApi::API
  end
end