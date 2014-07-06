require 'rubygems'

module JsonCrudApi
  class Service

    attr_accessor :log_service, :model, :scope_map

    def initialize(options)
      @log_service = options[:log_service]
      @model = options[:model]
      @scope_map = options[:scope_map]
    end

    # Create a record with the given attributes
    def create(params)
      @model.create(params)
    end

    # Determine if a record with the given key exists
    def exists?(key)
      @model.all(@model.key.first.name => key).count > 0
    end

    # Get all records
    def get_all
      @model.all
    end

    # Get the first record with the given key
    def get(key)
      @model.first(@model.key.first.name => key)
    end

    # Update a record with the given key with the given attributes
    # Returns false if the record does not exist.
    def update(key, params)
      record = get(key)
      return false if record.nil?

      record.update(params)
    end

    # Delete a record with the given key
    # Returns false if the record does not exist.
    def delete(key)
      record = get(key)
      return false if record.nil?

      record.destroy
    end

    # Find if the params are valid for an operation (defaults to true)
    def valid_for?(params, operation, api_instance)
      true
    end

    # Determine if the current user is authorized for the given operation
    def user_authorized_for?(user, operation)
      # Auth is disabled if scope map is nil
      return true if @scope_map.nil?
      # Auth succeeds if there is no map for this operation
      return true if @scope_map[operation].nil?
      # Auth fails if user is not logged in
      return false if user.nil?
      # Auth fails if user has no scopes
      return false unless user.has_key?(:scopes) 
      return false unless user[:scopes].is_a?(Array)
      return false if user[:scopes].empty?

      if @scope_map[operation].is_a?(Array)
        # Auth succeeds if the intersection of allowed scopes and mapped scopes is non-empty.
        return !((@scope_map[operation] & user[:scopes]).empty?)
      end

      # Auth succeeds if the mapped scope is singular and the user posesses it
      user[:scopes].include?(@scope_map[operation])
    end
  end
end