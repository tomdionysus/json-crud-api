require "rubygems"
require "json"

module JsonApi
  class AuthClient

    attr_reader :redis, :session_ttl, :prefix

    def initialize(options)
      @redis = options[:redis_client]
      @session_ttl = options[:session_ttl]
      @prefix = options[:key_prefix]
    end

    def get(key)
      data = @redis.get(get_redis_key(key))
      return nil if data.nil?
      touch(key)
      JSON.parse(data, :symbolize_names => true)
    end

    def delete(key)
      return false unless @redis.exists(get_redis_key(key))
      @redis.del(get_redis_key(key))
      true
    end

    def touch(key)
      return false unless @redis.exists(get_redis_key(key))
      @redis.expire(get_redis_key(key), @session_ttl)
      true
    end
  end
end