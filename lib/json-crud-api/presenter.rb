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
      properties = exclude_properties! properties, method, operation unless @exclude.nil?
      properties = include_properties! properties, method, operation unless @include.nil?
      properties
    end

    def exclude_properties!(properties, method, operation)
      properties -= @exclude[:all] unless @exclude[:all].nil?
      properties -= @exclude[operation] unless @exclude[operation].nil?
      unless @exclude[method].nil?
        properties -= @exclude[method][:all] unless @exclude[method][:all].nil?
        properties -= @exclude[method][operation] unless @exclude[method][operation].nil?
      end
      properties
    end

    def include_properties!(properties, method, operation)
      properties += @include[:all] unless @include[:all].nil?
      properties += @include[operation] unless @include[operation].nil?
      unless  @include[method].nil?
        properties += @include[method][:all] unless @include[method][:all].nil?
        properties += @include[method][operation] unless @include[method][operation].nil?
      end
      properties
    end

  end
end