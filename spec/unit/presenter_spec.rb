require "helper"

describe JsonCrudApi::Presenter do
  before(:each) do
    @mock_model = double('model')

    @presenter = JsonCrudApi::Presenter.new({
      :model => @mock_model,
    })
  end

  describe '#initialize' do
    it 'should inject dependencies correctly' do
      @presenter.model.should be @mock_model
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
  end
end