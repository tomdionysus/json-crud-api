module JsonCrudApi
  class Presenter

    attr_accessor :model, :exclude

    def initialize(options)
      @model = options[:model]
      @exclude = options[:exclude]

      throw "Model must be defined" if @model.nil?
    end

    def render(data, operation = nil)
      return data.map {|d| render(d, operation) } if data.is_a?(Array)

      properties = @model.properties.map { |p| p.name.to_sym }
      unless @exclude.nil? or @exclude[:render].nil? 
        properties -= @exclude[:render][:all] unless @exclude[:render][:all].nil?
        properties -= @exclude[:render][operation] unless @exclude[:render][operation].nil?
      end

      Hash[properties.map { |p| [p, data.send(p)] }]
    end

    def parse(data, operation = nil)
      return data.map {|d| parse(d, operation) } if data.is_a?(Array)

      properties = @model.properties.map { |p| p.name.to_sym }
      unless @exclude.nil? or @exclude[:parse].nil? 
        properties -= @exclude[:parse][:all] unless @exclude[:parse][:all].nil?
        properties -= @exclude[:parse][operation] unless @exclude[:parse][operation].nil?
      end

      Hash[properties.map { |p| [p,data[p]] }]
    end

  end
end