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
    it 'should set user nil on self and services if :auth_client not configured' do

      service = double('service')

      @test.test_env = "abcdefg"

      @test.settings = OpenStruct.new({
        :services => { :test => service }
      })
      @test.test_env = {}

      expect(service).to receive(:set_user).with(nil)

      @test.process_session

      expect(@test.user).to be_nil
      expect(@test.logged_in).to be false
    end

    it 'should handle services that do not have set_user if :auth_client not configured' do
      service = double('service')

      @test.test_env = "abcdefg"

      @test.settings = OpenStruct.new({
        :services => { :test => service }
      })
      @test.test_env = {}

      @test.process_session

      expect(@test.user).to be_nil
      expect(@test.logged_in).to be false
    end

    it 'should call auth_client get with session key and set logged_in false and services set_user nil if nil' do
      service = double('service')

      @test.test_env = { 'HTTP_X_SESSION_ID' => "abcdefg" }

      @test.settings = OpenStruct.new({
        :auth_client => OpenStruct.new,
        :services => { :test => service }
      })

      expect(service).to receive(:set_user).with(nil)

      expect(@test.settings[:auth_client]).to receive(:get).with('abcdefg').and_return(nil)

      @test.process_session

      expect(@test.user).to be_nil
      expect(@test.logged_in).to be false
    end

    it 'should call auth_client get with session key and set user and logged_in true if not nil' do
      service = double('service')

      @test.test_env = { 'HTTP_X_SESSION_ID' => "abcdefg" }

      @test.settings = OpenStruct.new({
        :auth_client => OpenStruct.new,
        :services => { :test => service }
      })

      expect(@test.settings[:auth_client]).to receive(:get).with('abcdefg').and_return({:name=>"Tom"})

      @test.process_session

      expect(@test.user).to eq({:name=>"Tom"})
      expect(@test.logged_in).to be true
    end

    it 'should call set_user with returned user on each service on session get not nil' do
      service = double('service')

      @test.test_env = { 'HTTP_X_SESSION_ID' => "abcdefg" }

      @test.settings = OpenStruct.new({
        :auth_client => OpenStruct.new,
        :services => { :test => service }
      })

      expect(@test.settings[:auth_client]).to receive(:get).with('abcdefg').and_return({:name=>"Horace"})
      expect(service).to receive(:set_user).with({:name=>'Horace'})

      @test.process_session
    end
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