require "helper"

describe JsonCrudApi::Presenter do
  before(:each) do
    @mock_model = double('model')

    @presenter = JsonCrudApi::Presenter.new({
      :model => @mock_model,
      :include => { :no_operation => 10 },
      :exclude => { :no_operation => 11 }
    })
  end

  describe '#initialize' do
    it 'should inject dependencies correctly' do
      expect(@presenter.model).to be @mock_model
      expect(@presenter.include).to eq({ :no_operation => 10 })
      expect(@presenter.exclude).to eq({ :no_operation => 11 })
    end

    it 'should throw an exception if model is not set' do
    end
  end

  describe '#render' do
    it 'should output a single property in data based on model properties' do
      expect(@mock_model).to receive(:properties)
        .and_return([OpenStruct.new(:name => :one)])
      data = OpenStruct.new(:one => "Test")

      expect(@presenter.render(data)).to eq({ :one => "Test" })
    end

    it 'should not return data properties that do not have model properties' do
      expect(@mock_model).to receive(:properties)
        .and_return([OpenStruct.new(:name => :one)])
      data = OpenStruct.new(:one => "YES", :two => "OK")

      expect(@presenter.render(data)).to eq({ :one => "YES" })
    end

    it 'should return nil for model properties that do not have data' do
      expect(@mock_model).to receive(:properties)
        .and_return([
          OpenStruct.new(:name => :one),
          OpenStruct.new(:name => :two),
        ])
      data = OpenStruct.new(:two => "OK")

      expect(@presenter.render(data)).to eq({ :one => nil, :two => 'OK' })
    end

    it 'should call itself when supplied with an array and return an array of the results' do
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one)]
      )

      data = [OpenStruct.new(:one => "Test"), OpenStruct.new(:one => "TEST2")]

      expect(@presenter.render(data)).to eq([{ :one => "Test" }, { :one => "TEST2" }])
    end

    it 'should include render:all properties' do
      @presenter.include = { :render => { :all => [:five] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :two)]
      )
      
      data = OpenStruct.new(:two => "Two",:five=>"Five")

      expect(@presenter.render(data)).to eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should include global:all properties' do
      @presenter.include = { :all => [:five] }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:two => "Two",:five=>"Five")

      expect(@presenter.render(data)).to eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should include global:operation properties' do
      @presenter.include = { :test => [:five] }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:two => "Two",:five=>"Five")

      expect(@presenter.render(data, :test)).to eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should include render:operation properties' do
      @presenter.include = { :render => { :test => [:five] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:two => "Two",:five=>"Five")

      expect(@presenter.render(data, :test)).to eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should exclude render:all properties' do
      @presenter.exclude = { :render => { :all => [:one] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:one => "Test",:two => "Two")

      expect(@presenter.render(data)).to eq({ :two => "Two" }) 
    end

    it 'should exclude global:all properties' do
      @presenter.exclude = { :all => [:one] }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:one => "Test",:two => "Two")

      expect(@presenter.render(data)).to eq({ :two => "Two" }) 
    end

    it 'should exclude render:operation properties' do
      @presenter.exclude = { :render => { :test => [:one] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:one => "Test",:two => "Two")

      expect(@presenter.render(data, :test)).to eq({ :two => "Two" }) 
    end

    it 'should exclude global:operation properties' do
      @presenter.exclude = { :test => [:one] }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:one => "Test",:two => "Two")

      expect(@presenter.render(data, :test)).to eq({ :two => "Two" }) 
    end

    it 'should exclude combinations of render:all and render:operation properties' do
      @presenter.exclude = { :render => { :all => [:two] , :test => [:one] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two), OpenStruct.new(:name => :three)]
      )
      data = OpenStruct.new(:one => "Test",:two => "Two",:three => "Three")

      expect(@presenter.render(data, :test)).to eq({ :three => "Three" }) 
    end
  end

  describe '#parse' do
    it 'should output a single property in data based on model properties' do
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one)]
      )
      data = { :one => 1 }
      expect(@presenter.parse(data)).to eq({:one => 1})
    end

    it 'should not output properties of data that are not in model properties' do
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one)]
      )
      data = { :one => 1, :two => 2 }
      expect(@presenter.parse(data)).to eq({:one => 1})
    end

    it 'should not output model properties with no data property' do
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one),OpenStruct.new(:name => :two)]
      )
      data = { :two => 2 }
      expect(@presenter.parse(data)).to eq({:two => 2})
    end

    it 'should call itself when supplied with an array and return an array of the results' do
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one)]
      )

      data = [{ :one => 1 }]

      expect(@presenter.parse(data)).to eq([{ :one => 1 }])
    end

    it 'should exclude parse:all properties' do
      @presenter.exclude = { :parse => { :all => [:one] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:one => "Test",:two => "Two")

      expect(@presenter.parse(data)).to eq({ :two => "Two" }) 
    end

    it 'should exclude parse:operation properties' do
      @presenter.exclude = { :parse => { :test => [:one] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      )

      data = OpenStruct.new(:one => "Test",:two => "Two")

      expect(@presenter.parse(data, :test)).to eq({ :two => "Two" }) 
    end

    it 'should exclude combinations of parse:all and parse:operation properties' do
      @presenter.exclude = { :parse => { :all => [:two] , :test => [:one] } }
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two), OpenStruct.new(:name => :three)]
      )
      data = OpenStruct.new(:one => "Test",:two => "Two",:three => "Three")

      expect(@presenter.parse(data, :test)).to eq({ :three => "Three" }) 
    end

    it 'should not supply keys that are not in the supplied data' do
      expect(@mock_model).to receive(:properties).and_return(
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two), OpenStruct.new(:name => :three)]
      )

      data = OpenStruct.new(:one => "Test",:two => "Two")

      expect(@presenter.parse(data, :test).keys).to_not include :three
    end
  end
end