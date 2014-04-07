module JsonCrudApi
  class Presenter

    attr_accessor :model

    def initialize(options)
      @model = options[:model]

      throw "Model must be defined" if @model.nil?
    end

    def render(data)
      return data.map {|d| render(d) } if data.is_a?(Array)

      Hash[@model.properties.map { |p| [p.name, data.send(p.name.to_sym)] }]
    end

    def parse(data)
      return data.map {|d| parse(d) } if data.is_a?(Array)

      properties = (@model.properties.map { |property| property.name.to_sym }) & (data.keys.map { |key| key.to_sym})
      
      Hash[properties.map { |p| [p,data[p]] }]
    end

  end
end