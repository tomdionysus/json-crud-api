require 'rubygems'

module JsonApi
  class Service

    def initialize(options)
      @log_service = options[:log_service]
      @repo = options[:repository]
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
  end
end