require 'json'

module JsonCrudApi
  module JsonPayload
    def process_json_payload
      request.body.rewind
      body = request.body.read 
      unless body.length > 2
        @payload = nil
        return
      end

      begin
        @payload = JSON.parse body, :symbolize_names => true
      rescue JSON::ParserError
        @payload = nil
        fail_with_error 422, 'JSON_PARSE_ERROR',  'The JSON payload cannot be parsed'
      end
    end
  end
end