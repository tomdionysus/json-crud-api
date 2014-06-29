require 'json'

module JsonCrudApi
  module Crud

    def crud_api(url, key, options = [])

      unless options.include? :disable_read
        crud_api_get_all(url, key) unless options.include? :disable_get_all
        crud_api_get(url, key) unless options.include? :disable_get
      end

      unless options.include? :disable_write
        crud_api_post(url, key) unless options.include? :disable_post
        crud_api_put(url, key) unless options.include? :disable_put
        crud_api_delete(url, key) unless options.include? :disable_delete
      end

    end

    private

    def crud_api_get_all(url, key)
      get url do
        service = settings.services[key]
        presenter = settings.presenters[key]
        fail_unauthorized unless service.user_authorized_for? :get_all
        entities = service.get_all
        fail_not_found if entities.nil?

        JSON.fast_generate settings.presenters[key].render(entities, :get_all)
      end
    end

    def crud_api_get(url, key)
      get url+"/:id" do
        service = settings.services[key]
        presenter = settings.presenters[key]
        fail_unauthorized unless service.user_authorized_for? :get
        entity = service.get(params["id"])
        fail_not_found if entity.nil?

        JSON.fast_generate settings.presenters[key].render(entity, :get)
      end
    end

    def crud_api_post(url, key)
      post url do
        service = settings.services[key]
        presenter = settings.presenters[key]
        fail_unauthorized unless service.user_authorized_for? :create
        entity = service.create(presenter.parse(@payload, :post))

        JSON.fast_generate settings.presenters[key].render(entity, :post)
      end
    end

    def crud_api_put(url, key)
      put url+"/:id" do
        service = settings.services[key]
        presenter = settings.presenters[key]
        fail_unauthorized unless service.user_authorized_for? :update
        fail_not_found unless service.update(params["id"], presenter.parse(@payload, :put))
        entity = service.get(params["id"])
        JSON.fast_generate settings.presenters[key].render(entity, :put)
      end
    end

    def crud_api_delete(url, key)
      delete url+"/:id" do
        service = settings.services[key]
        presenter = settings.presenters[key]
        fail_unauthorized unless service.user_authorized_for? :delete
        fail_not_found unless service.delete(params["id"])
        204
      end
    end
  end
end