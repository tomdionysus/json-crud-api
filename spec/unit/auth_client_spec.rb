require "helper"

describe JsonCrudApi::AuthClient do
  before(:each) do
    @mock_redis = double('redis')

    @client = JsonCrudApi::AuthClient.new({
      :redis_client => @mock_redis,
      :session_ttl => 200,
      :key_prefix => 789
    })
  end

  describe '#initialize' do
    it 'should inject dependencies correctly' do
      @client.redis.should be @mock_redis
      @client.session_ttl.should be 200
      @client.prefix.should be 789
    end
  end

  describe '#get' do
    it 'should call get_redis_key and redis get' do
      @client.should_receive(:get_redis_key).with('one')
      @mock_redis.should_receive(:get).and_return nil
      @client.get('one')
    end

    it 'should return nil if redis get return nil' do
      @mock_redis.should_receive(:get).and_return nil
      @client.get('one').should be nil
    end

    it 'should call touch if redis get is non nil' do
      @mock_redis.should_receive(:get).and_return '{}'
      @client.should_receive(:touch).with('789one')
      @client.get('one')
    end

    it 'should parse JSON from redis get' do
      @mock_redis.should_receive(:get).and_return '{"five":5}'
      @client.should_receive(:touch).with('789one')
      @client.get('one').should eq({ :five => 5 })
    end
  end

  describe '#delete' do
    it 'should call get_redis_key and redis exists and return false if exists is false' do
      @client.should_receive(:get_redis_key).with('one')
      @mock_redis.should_receive(:exists).and_return false
      @client.delete('one').should be false
    end

    it 'should call redis del and return true if redis exists is true' do
      @mock_redis.should_receive(:exists).and_return true
      @mock_redis.should_receive(:del).with('789one')
      @client.delete('one').should be true
    end
  end

  describe '#touch' do
    it 'should call get_redis_key and redis exists and return false if exists is false' do
      @client.should_receive(:get_redis_key).with('one')
      @mock_redis.should_receive(:exists).and_return false
      @client.touch('one').should be false
    end

    it 'should call redis expire and return true if redis exists is true' do
      @mock_redis.should_receive(:exists).and_return true
      @mock_redis.should_receive(:expire).with('789one', 200)
      @client.touch('one').should be true
    end
  end

  describe '#get_redis_key' do
    it 'should return key if prefix is nil' do
      @client.prefix = nil
      @client.get_redis_key('one').should eq 'one'
    end

    it 'should return key.to_s if prefix is nil' do
      @client.prefix = nil
      @client.get_redis_key(1).should eq '1'
    end

    it 'should return prefix plus key if prefix is not nil' do
      @client.prefix = 'pre-'
      @client.get_redis_key('one').should eq 'pre-one'
    end

    it 'should return prefix plus key.to_s if prefix is not nil' do
      @client.prefix = 'post-'
      @client.get_redis_key(1).should eq 'post-1'
    end

    it 'should return prefix.to_s plus key.to_s if prefix is not nil' do
      @client.prefix = 5
      @client.get_redis_key(1).should eq '51'
    end
  end
end