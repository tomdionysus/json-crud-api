require "spec_helper"

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
      expect(@client.redis).to be @mock_redis
      expect(@client.session_ttl).to be 200
      expect(@client.prefix).to be 789
    end
  end

  describe '#get' do
    it 'should call get_redis_key and redis get' do
      expect(@client).to receive(:get_redis_key).with('one')
      expect(@mock_redis).to receive(:get).and_return nil
      @client.get('one')
    end

    it 'should return nil if redis get return nil' do
      expect(@mock_redis).to receive(:get).and_return nil
      expect(@client.get('one')).to be_nil
    end

    it 'should call touch if redis get is non nil' do
      expect(@mock_redis).to receive(:get).and_return '{}'
      expect(@client).to receive(:touch).with('789one')
      @client.get('one')
    end

    it 'should parse JSON from redis get' do
      expect(@mock_redis).to receive(:get).and_return '{"five":5}'
      expect(@client).to receive(:touch).with('789one')
      expect(@client.get('one')).to eq({ :five => 5 })
    end
  end

  describe '#delete' do
    it 'should call get_redis_key and redis exists and return false if exists is false' do
      expect(@client).to receive(:get_redis_key).with('one')
      expect(@mock_redis).to receive(:exists).and_return false
      expect(@client.delete('one')).to be false
    end

    it 'should call redis del and return true if redis exists is true' do
      expect(@mock_redis).to receive(:exists).and_return true
      expect(@mock_redis).to receive(:del).with('789one')
      expect(@client.delete('one')).to be true
    end
  end

  describe '#touch' do
    it 'should call get_redis_key and redis exists and return false if exists is false' do
      expect(@client).to receive(:get_redis_key).with('one')
      expect(@mock_redis).to receive(:exists).and_return false
      expect(@client.touch('one')).to be false
    end

    it 'should call redis expire and return true if redis exists is true' do
      expect(@mock_redis).to receive(:exists).and_return true
      expect(@mock_redis).to receive(:expire).with('789one', 200)
      expect(@client.touch('one')).to be true
    end
  end

  describe '#get_redis_key' do
    it 'should return key if prefix is nil' do
      @client.prefix = nil
      expect(@client.get_redis_key('one')).to eq 'one'
    end

    it 'should return key.to_s if prefix is nil' do
      @client.prefix = nil
      expect(@client.get_redis_key(1)).to eq '1'
    end

    it 'should return prefix plus key if prefix is not nil' do
      @client.prefix = 'pre-'
      expect(@client.get_redis_key('one')).to eq 'pre-one'
    end

    it 'should return prefix plus key.to_s if prefix is not nil' do
      @client.prefix = 'post-'
      expect(@client.get_redis_key(1)).to eq 'post-1'
    end

    it 'should return prefix.to_s plus key.to_s if prefix is not nil' do
      @client.prefix = 5
      expect(@client.get_redis_key(1)).to eq '51'
    end
  end
end