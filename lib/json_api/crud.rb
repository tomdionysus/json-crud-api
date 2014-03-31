module JsonApi
  module Crud

    def crud_api(url, key, options = [])

      unless options.include? :disable_read

        unless options.include? :disable_get_all
          get url do
            entities = settings.services[key].get_all
            fail_not_found if entity.nil?

            JSON.fast_generate settings.presenters[key].render(entities)
          end
        end

        unless options.include? :disable_get
          get url+"/:id" do
            entity = settings.services[key].get(params["id"])
            fail_not_found if entity.nil?

            JSON.fast_generate settings.presenters[key].render(entity)
          end
        end

      end

      unless options.include? :disable_write

        unless options.include? :disable_post
          post url do
            entity = settings.services[key].create(@payload)

            JSON.fast_generate settings.presenters[key].render(entity)
          end
        end

        unless options.include? :disable_put
          put url+"/:id" do
            fail_not_found unless settings.services[key].update(params["id"], @payload)
            entity = settings.services[key].get(params["id"])
            JSON.fast_generate settings.presenters[key].render(entity)
          end
        end

        unless options.include? :disable_delete
          delete url+"/:id" do
            fail_not_found unless settings.services[key].update(params["id"], @payload) unless settings.services[key].delete(params["id"])
            204
          end
        end

      end
    end
  end
end