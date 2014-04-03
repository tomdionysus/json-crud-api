require 'rubygems'

module JsonCrudApi
  class Service

    attr_accessor :log_service, :repo, :user, :scope_map, :user_scopes

    def initialize(options)
      @log_service = options[:log_service]
      @repo = options[:repository]
      @scope_map = options[:scope_map]
      @user = nil
      @user_scopes = nil
    end

    # Create a record with the given attributes
    def create(params)
      @repo.create(params)
    end

    # Determine if a record with the given id exists
    def exists?(id)
      @repo.all(:id => id).count > 0
    end

    # Get all records
    def get_all
      @repo.all
    end

    # Get the first record with the given id
    def get(id)
      @repo.first(:id => id)
    end

    # Update a record with the given id with the given attributes
    # Returns false if the record does not exist.
    def update(id, params)
      record = get(id)
      return false if record.nil?

      record.update(params)
    end

    # Delete a record with the given id
    # Returns false if the record does not exist.
    def delete(id)
      record = get(id)
      return false if record.nil?

      record.destroy
    end

    # Set the current user
    def set_user(user)
      @user = user
      set_user_scopes(user[:scopes]) unless @user.nil?
    end

    # Set the current user scopes
    def set_user_scopes(user_scopes)
      @user_scopes = user_scopes
    end

    # Determine if the current user is authorized for the given operation
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