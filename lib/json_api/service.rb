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

    def get_all
      @repo.all
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
      set_user_scopes(user[:scopes]) unless @user.nil?
    end

    def set_user_scopes(user_scopes)
      @user_scopes = user_scopes
    end

    def user_authorized_for?(operation)
      # Auth is disabled if scope map is nil
      return true if @scope_map.nil?
      # Auth succeeds if there is no map for this operation
      return true if @scope_map[operation].nil?
      # Auth fails if user is not logged in
      return false if @user.nil?
      # Auth fails if user has no scopes
      return false if @user_scopes.nil? or @user_scopes.empty?

      if @scope_map[operation].is_a?(Array)
        # Auth succeeds if the intersection of allowed scopes and mapped scopes is non-empty.
        return !((@scope_map[operation] & @user_scopes).empty?)
      end

      # Auth succeeds if the mapped scope is singular and the user posesses it
      @user_scopes.include?(@scope_map[operation])
    end
  end
end