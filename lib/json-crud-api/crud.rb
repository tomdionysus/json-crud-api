require 'json'

module JsonCrudApi  
  module Crud
    def crud_get_all(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_unauthorized unless service.user_authorized_for? :get_all
      entities = service.get_all
      return fail_not_found if entities.nil?

      JSON.fast_generate presenter.render(entities, :get_all)
    end

    def crud_get(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_unauthorized unless service.user_authorized_for? :get
      entity = service.get(params["id"])
      return fail_not_found if entity.nil?

      JSON.fast_generate presenter.render(entity, :get)
    end

    def crud_post(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_unauthorized unless service.user_authorized_for? :create
      entity = service.create(presenter.parse(@payload, :post))

      JSON.fast_generate presenter.render(entity, :post)
    end

    def crud_put(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_unauthorized unless service.user_authorized_for? :update
      return fail_not_found unless service.update(params["id"], presenter.parse(@payload, :put))
      entity = service.get(params["id"])
      JSON.fast_generate presenter.render(entity, :put)
    end

    def crud_delete(key)
      service = settings.services[key]
      presenter = settings.presenters[key]
      return fail_unauthorized unless service.user_authorized_for? :delete
      return fail_not_found unless service.delete(params["id"])
      204
    end
  end
end