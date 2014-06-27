require 'json'

module JsonCrudApi
  module Crud

    def crud_api(url, key, options = [])

      unless options.include? :disable_read

        unless options.include? :disable_get_all
          get url do
            service = settings.services[key]
            presenter = settings.presenters[key]
            fail_unauthorized unless service.user_authorized_for? :get_all
            entities = service.get_all
            fail_not_found if entities.nil?

            JSON.fast_generate settings.presenters[key].render(entities, :get_all)
          end
        end

        unless options.include? :disable_get
          get url+"/:id" do
            service = settings.services[key]
            presenter = settings.presenters[key]
            fail_unauthorized unless service.user_authorized_for? :get
            entity = service.get(params["id"])
            fail_not_found if entity.nil?

            JSON.fast_generate settings.presenters[key].render(entity, :get)
          end
        end

      end

      unless options.include? :disable_write

        unless options.include? :disable_post
          post url do
            service = settings.services[key]
            presenter = settings.presenters[key]
            fail_unauthorized unless service.user_authorized_for? :create
            entity = service.create(presenter.parse(@payload, :post))

            JSON.fast_generate settings.presenters[key].render(entity, :post)
          end
        end

        unless options.include? :disable_put
          put url+"/:id" do
            service = settings.services[key]
            presenter = settings.presenters[key]
            fail_unauthorized unless service.user_authorized_for? :update
            fail_not_found unless service.update(params["id"], presenter.parse(@payload, :put))
            entity = service.get(params["id"])
            JSON.fast_generate settings.presenters[key].render(entity, :put)
          end
        end

        unless options.include? :disable_delete
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
  end
end