require "spec_helper"

describe JsonCrudApi::JsonPayload do

  before do
    class TestClass
      include JsonCrudApi::JsonPayload

      attr_accessor :request
    end

    @test = TestClass.new
  end

  describe '#process_json_payload' do
    it 'should call rewind on request.body' do

      @test.request = OpenStruct.new({
        :body => OpenStruct.new({
          :read => OpenStruct.new({:length => 0})
          })
      })
      expect(@test.request.body).to receive(:rewind)
      
      @test.process_json_payload
    end
  end

  # TODO: Moar Specs!
end
