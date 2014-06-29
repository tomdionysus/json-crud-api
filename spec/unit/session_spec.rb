require "spec_helper"

describe JsonCrudApi::Session do

  before do
    class TestClass
      attr_accessor :user, :logged_in, :auth_client, :settings, :test_env

      def env
        @test_env
      end

      include JsonCrudApi::Session
    end

    @test = TestClass.new
  end

  describe '#process_session' do
    it 'should return no user if :auth_client not configured' do

      @test.settings = OpenStruct.new({ 
        :auth_client => OpenStruct.new,
        :services => []
      })
      @test.test_env = {}

      expect(@test.settings[:auth_client]).not_to receive(:get)

      @test.process_session

      expect(@test.user).to be_nil
      expect(@test.logged_in).to be false
    end

    # TODO: Moar Specs!
  end

  describe '#logged_in?' do
    it 'should return the value of @logged_in' do
      @test.logged_in = true
      expect(@test.logged_in?).to be true
      @test.logged_in = false
      expect(@test.logged_in?).to be false
      @test.logged_in = nil
      expect(@test.logged_in?).to be nil
    end
  end
end