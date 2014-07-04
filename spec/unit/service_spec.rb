require "spec_helper"

describe JsonCrudApi::Service do
  before(:each) do
    @mock_model = double('model')
    @mock_log = double('Log')
    @mock_map = double('Map')

    @service = JsonCrudApi::Service.new({
      :log_service => @mock_log,
      :model => @mock_model,
      :scope_map => @mock_map
    })
  end

  describe '#initialize' do
    it 'should inject dependencies correctly' do
      expect(@service.log_service).to be @mock_log
      expect(@service.model).to be @mock_model
      expect(@service.scope_map).to be @mock_map
    end

    it 'should initialize user and scopes to nil' do
      expect(@service.user).to be nil
      expect(@service.user_scopes).to be nil
    end
  end

  describe '#create' do
    it 'should call create on model with params' do
      params = { :one => 'one', :two => 'two' }
      expect(@mock_model).to receive(:create).with(params).and_return(2)
      expect(@service.create(params)).to eq 2
    end
  end

  describe '#exists?' do
    it 'should call all on model with correct id' do
      query_object = OpenStruct.new :count => 1
      expect(@mock_model).to receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      expect(@mock_model).to receive(:all).with(:id => 3)
        .and_return(query_object)
      expect(@service.exists?(3)).to eq true
    end

    it 'should return false when count is zero' do
      query_object = OpenStruct.new :count => 0
      expect(@mock_model).to receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      expect(@mock_model).to receive(:all).with(:id => 3)
        .and_return(query_object)
      expect(@service.exists?(3)).to eq false
    end

    it 'should return true when count is one' do
      query_object = OpenStruct.new :count => 1
      expect(@mock_model).to receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      expect(@mock_model).to receive(:all).with(:id => 3)
        .and_return(query_object)
      expect(@service.exists?(3)).to eq true
    end

    it 'should return true when count is more than one' do
      query_object = OpenStruct.new :count => 2
      expect(@mock_model).to receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      expect(@mock_model).to receive(:all).with(:id => 3)
      .and_return(query_object)
      expect(@service.exists?(3)).to eq true
    end
  end

  describe '#get_all' do
    it 'should call all on model and return output' do
      expect(@mock_model).to receive(:all).and_return(67)
      expect(@service.get_all).to eq 67
    end
  end

  describe '#get' do
    it 'should call first on model with correct id and return result' do
        expect(@mock_model).to receive(:key)
          .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
        expect(@mock_model).to receive(:first).with({:id=>8}).and_return(123)
      expect(@service.get(8)).to eq 123
    end
  end

  describe '#update' do
    it 'should call get on service with correct id' do
      expect(@service).to receive(:get).with(5).and_return(nil)
      @service.update(5,nil)
    end

    it 'should return false if get returns nil' do
      expect(@service).to receive(:get).with(5).and_return(nil)
      expect(@service.update(5,nil)).to eq false
    end

    it 'should call update on record with correct params' do
      params = { :one => 'one', :two => 'two' }
      record = double('entity')
      expect(@service).to receive(:get).with(5)
      .and_return(record)
      expect(record).to receive(:update).with(params)
      .and_return(789)
      expect(@service.update(5,params)).to eq 789
    end
  end

  describe '#delete' do
    it 'should call get on service with correct id' do
      expect(@service).to receive(:get).with(5).and_return(nil)
      @service.delete(5)
    end

    it 'should return false if get returns nil' do
      expect(@service).to receive(:get).with(5).and_return(nil)
      expect(@service.delete(5)).to eq false
    end

    it 'should call delete on record' do
      record = double('entity')
      expect(@service).to receive(:get).with(5)
      .and_return(record)
      expect(record).to receive(:destroy).and_return(109)
      expect(@service.delete(5)).to eq 109
    end
  end

  describe '#set_user' do
    it 'should set user in service to param' do
      @service.set_user(nil)
      expect(@service.user).to eq nil
    end

    it 'should not call set_user_scopes if user is nil' do
      expect(@service).not_to receive(:set_user_scopes)
      @service.set_user(nil)
      expect(@service.user).to eq nil
    end

    it 'should call set_user_scopes if user is not' do
      user = { :scopes => [1,2] }
      expect(@service).to receive(:set_user_scopes).with([1,2])
      @service.set_user(user)
      expect(@service.user).to eq user
    end
  end

  describe '#set_user_scopes' do
    it 'should set user_scopes in service to param' do
      @service.set_user_scopes(nil)
      expect(@service.user_scopes).to eq nil

      @service.set_user_scopes(234234)
      expect(@service.user_scopes).to eq 234234
    end
  end

  describe '#valid_for?' do
    it 'should return true' do
      expect(@service.valid_for?(nil,nil,nil)).to be true
    end
  end

  describe '#user_authorized_for?' do
    it 'should return true if scope_map is nil' do
      @service.scope_map = nil
      expect(@service.user_authorized_for?(:one)).to be true
    end

    it 'should return true if scope_map is not nil but no map for operation' do
      @service.scope_map = { :two => 'TWO' }
      expect(@service.user_authorized_for?(:one)).to be true
    end

    it 'should return false if user is nil' do
      @service.scope_map = { :two => 'TWO' }
      @service.user = nil
      expect(@service.user_authorized_for?(:two)).to be false
    end

    it 'should return false if user has nil scopes' do
      @service.scope_map = { :two => 'TWO' }
      @service.user = { :name => "Tom" }
      @service.user_scopes = nil
      expect(@service.user_authorized_for?(:two)).to be false
    end

    it 'should return false if user has empty scopes' do
      @service.scope_map = { :two => 'TWO' }
      @service.user = { :name => "Tom" }
      @service.user_scopes = []
      expect(@service.user_authorized_for?(:two)).to be false
    end

    it 'should return true if scope map exists in user scopes' do
      @service.scope_map = { :two => 'FIVE'}
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'FIVE']
      expect(@service.user_authorized_for?(:two)).to be true
    end

    it 'should return false if scope map does not exist in user scopes' do
      @service.scope_map = { :two => 'SEVEN'}
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'FIVE']
      expect(@service.user_authorized_for?(:two)).to be false
    end

    it 'should return true if scope map is array and shares one scope with user' do
      @service.scope_map = { :two => ['TWO'] }
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'THREE']
      expect(@service.user_authorized_for?(:two)).to be true
    end

    it 'should return true if scope map is array and shares more than one scope with user' do
      @service.scope_map = { :two => ['TWO','THREE'] }
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'THREE']
      expect(@service.user_authorized_for?(:two)).to be true
    end

    it 'should return false if scope map is array and does not share scopes with user' do
      @service.scope_map = { :two => ['FOUR'] }
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'THREE']
      expect(@service.user_authorized_for?(:two)).to be false
    end
  end
end