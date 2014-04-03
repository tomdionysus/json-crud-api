require 'rubygems'

module JsonCrudApi
  class AuthClient

    attr_accessor :redis, :session_ttl, :prefix

    def initialize(options)
      @redis = options[:redis_client]
      @session_ttl = options[:session_ttl]
      @prefix = options[:key_prefix]
    end

    def get(key)
      key = get_redis_key(key)
      data = @redis.get(key)
      return nil if data.nil?
      touch(key)
      JSON.parse(data, :symbolize_names => true)
    end

    def delete(key)
      key = get_redis_key(key)
      return false unless @redis.exists(key)
      @redis.del(key)
      true
    end

    def touch(key)
      key = get_redis_key(key)
      return false unless @redis.exists(key)
      @redis.expire(key, @session_ttl)
      true
    end

    def get_redis_key(key)
      return key.to_s if @prefix.nil?
      @prefix.to_s+key.to_s
    end
  end
end