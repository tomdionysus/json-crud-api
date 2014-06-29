require "spec_helper"

describe JsonCrudApi::API do
  include Rack::Test::Methods

  def app
    JsonCrudApi::API
  end

  # TODO: Moar Specs!
end