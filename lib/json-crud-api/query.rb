require 'cgi'

module JsonCrudApi
  class Query
    attr_accessor :valid, :mode, :arguments, :include_fields, :exclude_fields, :link_relations, :embed_relations, :errors

    def initialize(str)
      @mode = :default
      @arguments = []
      @include_fields = []
      @exclude_fields = []
      @errors = []
      @link_relations = []
      @embed_relations = []
      @valid = true
      parse_from(str)
    end

    def parse_from(str)
      return if str.nil? or str.empty?

      @arguments = CGI::parse(str)

      @arguments.each do |key, fields|
        case key
        when '_include'
          @valid &&= set_mode_and_fields(:explicit, fields) do |field| 
            @include_fields << field
         end

        when '_exclude'
          @valid &&= set_mode_and_fields(:implicit, fields) do |field| 
            @exclude_fields << field
          end

        when '_link'
          set_relations(fields) do |relation|
            @link_relations << relation
          end

        when '_embed'
          set_relations(fields) do |relation|
            @embed_relations << relation
          end
        end
      end
    end

    private

    def set_mode_and_fields(mode, fields_array)
      return add_error(:ambiguous_mode,'Ambiguous mode - do not set both _include and _exclude') if @mode != :default

      @mode = mode
      fields_array.each do |val|
        val.split(',').each do |field_path|
          yield self.class.parse_field(field_path)
        end
      end
    end

    def set_relations(fields_array)
      fields_array.each do |val|
        val.split(',').each do |field_path|
          yield self.class.parse_field(field_path)
        end
      end
    end

    def self.parse_field(field_path)
      paths = field_path.split('.')
      last = paths.pop
      { :name => last, :path => paths }
    end

    def add_error(code, message, ref = nil)
      errors << { :code => code, :message => message, :ref => ref }
      @valid = false
    end
  end
end