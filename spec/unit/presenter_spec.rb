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
      @presenter.model.should be @mock_model
      @presenter.include.should eq({ :no_operation => 10 })
      @presenter.exclude.should eq({ :no_operation => 11 })
    end

    it 'should throw an exception if model is not set' do
    end
  end

  describe '#render' do
    it 'should output a single property in data based on model properties' do
      @mock_model.should_receive(:properties)
        .and_return([OpenStruct.new(:name => :one)])
      data = OpenStruct.new(:one => "Test")

      @presenter.render(data).should eq({ :one => "Test" })
    end

    it 'should not return data properties that do not have model properties' do
      @mock_model.should_receive(:properties)
        .and_return([OpenStruct.new(:name => :one)])
      data = OpenStruct.new(:one => "YES", :two => "OK")

      @presenter.render(data).should eq({ :one => "YES" })
    end

    it 'should return nil for model properties that do not have data' do
      @mock_model.should_receive(:properties)
        .and_return([
          OpenStruct.new(:name => :one),
          OpenStruct.new(:name => :two),
        ])
      data = OpenStruct.new(:two => "OK")

      @presenter.render(data).should eq({ :one => nil, :two => 'OK' })
    end

    it 'should call itself when supplied with an array and return an array of the results' do
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one)]
      end
      data = [OpenStruct.new(:one => "Test"), OpenStruct.new(:one => "TEST2")]

      @presenter.render(data).should eq([{ :one => "Test" }, { :one => "TEST2" }])
    end

    it 'should include render:all properties' do
      @presenter.include = { :render => { :all => [:five] } }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:two => "Two",:five=>"Five")

      @presenter.render(data).should eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should include global:all properties' do
      @presenter.include = { :all => [:five] }
      @mock_model.stub :properties do
        [ OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:two => "Two",:five=>"Five")

      @presenter.render(data).should eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should include global:operation properties' do
      @presenter.include = { :test => [:five] }
      @mock_model.stub :properties do
        [ OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:two => "Two",:five=>"Five")

      @presenter.render(data, :test).should eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should include render:operation properties' do
      @presenter.include = { :render => { :test => [:five] } }
      @mock_model.stub :properties do
        [ OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:two => "Two",:five=>"Five")

      @presenter.render(data, :test).should eq({ :two => "Two", :five=>"Five" }) 
    end

    it 'should exclude render:all properties' do
      @presenter.exclude = { :render => { :all => [:one] } }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two")

      @presenter.render(data).should eq({ :two => "Two" }) 
    end

    it 'should exclude global:all properties' do
      @presenter.exclude = { :all => [:one] }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two")

      @presenter.render(data).should eq({ :two => "Two" }) 
    end

    it 'should exclude render:operation properties' do
      @presenter.exclude = { :render => { :test => [:one] } }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two")

      @presenter.render(data, :test).should eq({ :two => "Two" }) 
    end

    it 'should exclude global:operation properties' do
      @presenter.exclude = { :test => [:one] }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two")

      @presenter.render(data, :test).should eq({ :two => "Two" }) 
    end

    it 'should exclude combinations of render:all and render:operation properties' do
      @presenter.exclude = { :render => { :all => [:two] , :test => [:one] } }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two), OpenStruct.new(:name => :three)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two",:three => "Three")

      @presenter.render(data, :test).should eq({ :three => "Three" }) 
    end
  end

  describe '#parse' do
    it 'should output a single property in data based on model properties' do
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one)]
      end
      data = { :one => 1 }
      @presenter.parse(data).should eq({:one => 1})
    end

    it 'should not output properties of data that are not in model properties' do
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one)]
      end
      data = { :one => 1, :two => 2 }
      @presenter.parse(data).should eq({:one => 1})
    end

    it 'should not output model properties with no data property' do
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one)]
        [OpenStruct.new(:name => :two)]
      end
      data = { :two => 2 }
      @presenter.parse(data).should eq({:two => 2})
    end

    it 'should call itself when supplied with an array and return an array of the results' do
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one)]
      end
      data = [{ :one => 1 }]

      @presenter.parse(data).should eq([{ :one => 1 }])
    end

    it 'should exclude parse:all properties' do
      @presenter.exclude = { :parse => { :all => [:one] } }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two")

      @presenter.parse(data).should eq({ :two => "Two" }) 
    end

    it 'should exclude parse:operation properties' do
      @presenter.exclude = { :parse => { :test => [:one] } }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two")

      @presenter.parse(data, :test).should eq({ :two => "Two" }) 
    end

    it 'should exclude combinations of parse:all and parse:operation properties' do
      @presenter.exclude = { :parse => { :all => [:two] , :test => [:one] } }
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two), OpenStruct.new(:name => :three)]
      end
      data = OpenStruct.new(:one => "Test",:two => "Two",:three => "Three")

      @presenter.parse(data, :test).should eq({ :three => "Three" }) 
    end

    it 'should not supply keys that are not in the supplied data' do
      @mock_model.stub :properties do
        [OpenStruct.new(:name => :one), OpenStruct.new(:name => :two), OpenStruct.new(:name => :three)]
      end

      data = OpenStruct.new(:one => "Test",:two => "Two")

      @presenter.parse(data, :test).keys.should_not include :three
    end
  end
end