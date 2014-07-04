require 'json'

module JsonCrudApi
  module JsonErrors

    def clear_errors 
      @errors = []
    end

    def add_error(code, message, reference = nil)
      @errors = [] if @errors.nil?

      error = {
        :code => code,
        :message => message,
      }
      error[:reference] = reference unless reference.nil?
      @errors.push error
    end

    def fail_with_error(status, code, message, reference = nil)
      add_error code,message,reference
      fail_with_errors status
    end

    def fail_with_errors(status = 422)
      halt status, JSON.fast_generate({
        :success => false,
        :errors => @errors
      })
    end

    def fail_not_found
      fail_with_errors 404
    end

    def fail_unauthorized
      fail_with_error 401, 'UNAUTHORIZED','Authorization is required to perform this operation on the resource.'
    end

    def fail_forbidden
      fail_with_error 403, 'FORBIDDEN','The user is not allowed to perform this operation on the resource.'
    end
  end
end