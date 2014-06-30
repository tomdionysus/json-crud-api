require 'rubygems'
require 'sinatra'

module JsonCrudApi
  class API < Sinatra::Base

    include JsonCrudApi::Crud
    register JsonCrudApi::CrudExtension

    include JsonCrudApi::Session
    include JsonCrudApi::JsonPayload
    include JsonCrudApi::JsonErrors

    before do
      # HTTPS Only (if configured)
      if settings.respond_to? :https_only and settings.https_only and env['HTTPS'] != 'on' and env['HTTP_X_FORWARDED_PROTO'] != 'https'
        fail_with_error 403, 'SSL_ONLY', 'The API can only be accessed over SSL (HTTPS)'
      end

      # No-Cache by default
      cache_control :no_cache, :max_age => 0

      # Session
      process_session

      # JSON Payload
      process_json_payload

      # CORS
      content_type 'application/json; charset=utf-8'
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
    end

    not_found do
      fail_not_found
    end

    error do
      fail_with_error 500, 'INTERNAL_ERROR','The server has encountered an unknown error.'
    end

  end
end