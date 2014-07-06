require 'json'

module JsonCrudApi  
  module Crud
    def crud_get_all(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_forbidden unless service.user_authorized_for? @user, :get_all
      entities = service.get_all
      return fail_not_found if entities.nil?

      JSON.fast_generate presenter.render(entities, :get_all)
    end

    def crud_get(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_forbidden unless service.user_authorized_for? @user, :get
      entity = service.get(params["id"])
      return fail_not_found if entity.nil?

      JSON.fast_generate presenter.render(entity, :get)
    end

    def crud_post(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_forbidden unless service.user_authorized_for? @user, :create
      post_data = presenter.parse @payload, :post
      return fail_with_errors unless service.valid_for? post_data, :create, self
      entity = service.create post_data 
      JSON.fast_generate presenter.render(entity, :post)
    end

    def crud_put(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_forbidden unless service.user_authorized_for? @user, :update
      put_data = presenter.parse @payload, :put
      return fail_with_errors unless service.valid_for? put_data, :update, self
      return fail_not_found unless service.update params["id"], put_data
      entity = service.get params["id"]
      JSON.fast_generate presenter.render(entity, :put)
    end

    def crud_delete(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_forbidden unless service.user_authorized_for? @user, :delete
      return fail_not_found unless service.delete params["id"]
      204
    end
  end
end