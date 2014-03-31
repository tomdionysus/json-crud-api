require 'rubygems'

module JsonApi
  class Service

    def initialize(options)
      @log_service = options[:log_service]
      @repo = options[:repository]
      @user = nil
      @user_scopes = nil
    end
    
    def create(params)
      @repo.create(params)
    end

    def exists?(id)
      @repo.all(:id => id).count > 0
    end

    def get(id)
      @repo.first(:id => id)
    end

    def update(id, params)
      record = get(id)
      return false if record.nil?

      record.update(params)
    end

    def delete(id)
      record = get(id)
      return false if record.nil?

      record.destroy
    end

    def set_user(user)
      @user = user
      set_user_scopes @user[:scopes] unless @user.nil?
    end

    def set_user_scopes(user_scopes)
      @user_scopes = user_scopes
    end

    def user_has_scope?(scope)
      return true if @scope_map.nil?
      return false if @scope_map[scope].nil?
      @user_scopes.include?(@scope_map[scope])
    end

    def check_scope(scope)
      raise "user_scopes not set" if @user_scopes.nil? and not @scope_map.nil?
      raise "not_authorized" unless user_has_scope?(scope)
    end
  end
end