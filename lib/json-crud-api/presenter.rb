module JsonCrudApi
  class Presenter

    attr_accessor :model, :include, :exclude

    def initialize(options)
      @model = options[:model]
      @exclude = options[:exclude]
      @include = options[:include]

      # Properties Cache
      @properties = { :render => {}, :parse => {} }

      throw "Model must be defined" if @model.nil?
    end

    def render(data, operation = nil)
      return data.map {|d| render(d, operation) } if data.is_a?(Array)

      unless @properties[:render].has_key? operation
        @properties[:render][operation] = get_properties(:render, operation)
      end
      Hash[@properties[:render][operation].map { |p| [p, data.send(p)] }]
    end

    def parse(data, operation = nil)
      return data.map {|d| parse(d, operation) } if data.is_a?(Array)

      unless @properties[:parse].has_key? operation
        @properties[:parse][operation] = get_properties(:parse, operation)
      end

      out = Hash.new
      data.each_pair { |k,v| out[k] = v if @properties[:parse][operation].include?(k) }
      out
    end

    def get_properties(method, operation)
      properties = @model.properties.map { |p| p.name.to_sym }
      properties -= property_set @exclude, method, operation unless @exclude.nil?
      properties += property_set @include, method, operation unless @include.nil?
      properties
    end

    def property_set(parameter, method, operation)
      properties = []
            properties += parameter[:all] unless parameter[:all].nil?
      properties += parameter[operation] unless parameter[operation].nil?
      unless parameter[method].nil?
        properties += parameter[method][:all] unless parameter[method][:all].nil?
        properties += parameter[method][operation] unless parameter[method][operation].nil?
      end
      properties
    end
  end
end