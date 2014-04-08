module JsonCrudApi
  class Presenter

    attr_accessor :model, :include, :exclude

    def initialize(options)
      @model = options[:model]
      @exclude = options[:exclude]

      throw "Model must be defined" if @model.nil?
    end

    def render(data, operation = nil)
      return data.map {|d| render(d, operation) } if data.is_a?(Array)

      Hash[get_properties(:render, operation).map { |p| [p, data.send(p)] }]
    end

    def parse(data, operation = nil)
      return data.map {|d| parse(d, operation) } if data.is_a?(Array)

      Hash[get_properties(:parse, operation).map { |p| [p,data[p]] }]
    end

    def get_properties(method, operation)
      properties = @model.properties.map { |p| p.name.to_sym }
      unless @exclude.nil?
        properties -= @exclude[:all] unless @exclude[:all].nil?
        properties -= @exclude[operation] unless @exclude[operation].nil?
        unless @exclude[method].nil?
          properties -= @exclude[method][:all] unless @exclude[method][:all].nil?
          properties -= @exclude[method][operation] unless @exclude[method][operation].nil?
        end
      end
      unless @include.nil?
        properties += @include[:all] unless @include[:all].nil?
        properties += @include[operation] unless @include[operation].nil?
        unless  @include[method].nil?
          properties += @include[method][:all] unless @include[method][:all].nil?
          properties += @include[method][operation] unless @include[method][operation].nil?
        end
      end
      properties
    end

  end
end