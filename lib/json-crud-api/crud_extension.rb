require 'json'

module JsonCrudApi
  module CrudExtension
    def crud_api(url, key, options = [])

      unless options.include? :disable_read
        get url do crud_get_all(key) end unless options.include? :disable_get_all
        get url+"/:id" do crud_get(key) end unless options.include? :disable_get
      end

      unless options.include? :disable_write
        post url do crud_post(key) end unless options.include? :disable_post
        put url+"/:id" do crud_put(key) end unless options.include? :disable_put
        delete url+"/:id" do crud_delete(key) end unless options.include? :disable_delete
      end

    end
  end
end