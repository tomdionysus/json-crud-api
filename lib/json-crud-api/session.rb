require 'json'

module JsonCrudApi
  module Session
    def process_session
      @user = nil
      @logged_in = false
      if settings.respond_to? :auth_client
        @session_id = env['HTTP_X_SESSION_ID']
        unless @session_id.nil?
          @user = settings.auth_client.get(@session_id)
          @logged_in = !@user.nil?
        end
      end
      settings.services.each do |k,service|
        service.set_user @user if service.respond_to? :set_user
      end
    end

    def logged_in?
      @logged_in
    end
  end
end