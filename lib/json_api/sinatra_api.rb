require 'rubygems'
require 'json_api/crud'

module JsonApi
  class SinatraApi < Sinatra::Base

    register JsonApi::Crud

    before do
      # HTTPS Only (if configured)
      if settings.respond_to? :https_only and settings.https_only and env['HTTPS'] != 'on' and env['HTTP_X_FORWARDED_PROTO'] != 'https'
        fail_with_error 403, 'SSL_ONLY', 'The API can only be accessed over SSL (HTTPS)'
      end

      # JSON Errors
      @errors = []

      # Session
      if settings.respond_to? :auth_client
        @session_id = env['HTTP_X_SESSION_ID']
        if @session_id.nil?
          @user = nil
          @logged_in = false
        else
          @user = settings.auth_client.get(@session_id)
          @logged_in = !@user.nil?
          unless @user.nil?
            settings.services.each do |k,service|
              service.set_user @user if service.respond_to? :set_user
            end
          end
        end
      end

      # JSON Payload
      request.body.rewind
      body = request.body.read
      if body.length > 2
        begin
          @payload = JSON.parse body, :symbolize_names => true
        rescue JSON::ParserError
          fail_with_error 422, 'JSON_PARSE_ERROR',  'The JSON payload cannot be parsed'
        end
      else
        @payload = nil
      end

      # CORS
      content_type 'application/json; charset=utf-8'
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    end

    def logged_in?
      @logged_in
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
      fail_with_error 404, 'NOT_FOUND','The resource cannot be found'
    end

    not_found do
      fail_not_found
    end

    error do
      fail_with_error 500, 'INTERNAL_ERROR','The server has encountered an unknown error.'
    end

  end
end