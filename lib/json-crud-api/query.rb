require 'cgi'

module JsonCrudApi
  class Query

    VALID_OPERATIONS = [:eq, :ne, :lt, :gt, :lte, :gte, :like, :notlike]
    
    attr_accessor :valid, :mode, :arguments, :filters, :include_fields, :exclude_fields, :link_relations, :embed_relations, :errors

    def initialize(str)
      @mode = :default
      @arguments = []
      @include_fields = []
      @exclude_fields = []
      @errors = []
      @link_relations = []
      @embed_relations = []
      @filters = []
      @valid = true
      parse_from(str)
    end

    def valid?
      @valid
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

        else
          set_filters(key, fields) do |filter|
            @filters << filter
          end
        end
      end
    end

    private

    def set_filters(key, fields_array)
      fields_array.each do |val|
        val.split(',').each do |field_path|
          yield parse_operation(key, field_path)
        end
      end
    end

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

    def parse_operation(specifier, value)
      ops = specifier.split('|')
      h = self.class.parse_field(ops[0])
      h[:value] = value

      if ops.count == 1
        h[:operation] = :eq
        return h
      end

      h[:operation] = self.class.map_operation(ops[1])
      if h[:operation] == nil
        add_error(:unknown_operation,'Unknown Operation "'+ops[1]+'"',specifier)
        return nil
      end
      h
    end

    def self.map_operation(operation_str)
      return nil if operation_str.nil? or operation_str.empty?
      operation = operation_str.to_sym
      return nil unless VALID_OPERATIONS.include? operation
      operation
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