require "spec_helper"

describe JsonCrudApi::JsonErrors do

  before do
    class TestClass
      include JsonCrudApi::JsonErrors

      attr_accessor :errors

      def env
        @test_env
      end
    end

    @test = TestClass.new
  end

  describe '#clear_errors' do
    it 'should set @errors to []' do

      @test.errors = 9123878123
      @test.clear_errors

      expect(@test.errors).to eq []
    end
  end

  # TODO: Moar Specs!
end
