require "helper"

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
      @service.log_service.should be @mock_log
      @service.model.should be @mock_model
      @service.scope_map.should be @mock_map
    end

    it 'should initialize user and scopes to nil' do
      @service.user.should be nil
      @service.user_scopes.should be nil
    end
  end

  describe '#create' do
    it 'should call create on model with params' do
      params = { :one => 'one', :two => 'two' }
      @mock_model.should_receive(:create).with(params).and_return(2)
      @service.create(params).should eq 2
    end
  end

  describe '#exists?' do
    it 'should call all on model with correct id' do
      query_object = OpenStruct.new :count => 1
      @mock_model.should_receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      @mock_model.should_receive(:all).with(:id => 3)
        .and_return(query_object)
      @service.exists?(3).should eq true
    end

    it 'should return false when count is zero' do
      query_object = OpenStruct.new :count => 0
      @mock_model.should_receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      @mock_model.should_receive(:all).with(:id => 3)
        .and_return(query_object)
      @service.exists?(3).should eq false
    end

    it 'should return true when count is one' do
      query_object = OpenStruct.new :count => 1
      @mock_model.should_receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      @mock_model.should_receive(:all).with(:id => 3)
        .and_return(query_object)
      @service.exists?(3).should eq true
    end

    it 'should return true when count is more than one' do
      query_object = OpenStruct.new :count => 2
      @mock_model.should_receive(:key)
        .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
      @mock_model.should_receive(:all).with(:id => 3)
      .and_return(query_object)
      @service.exists?(3).should eq true
    end
  end

  describe '#get_all' do
    it 'should call all on model and return output' do
      @mock_model.should_receive(:all).with().and_return(67)
      @service.get_all.should eq 67
    end
  end

  describe '#get' do
    it 'should call first on model with correct id and return result' do
        @mock_model.should_receive(:key)
          .and_return(OpenStruct.new(:first => OpenStruct.new(:name => :id)))
        @mock_model.should_receive(:first).with({:id=>8}).and_return(123)
      @service.get(8).should eq 123
    end
  end

  describe '#update' do
    it 'should call get on service with correct id' do
      @service.should_receive(:get).with(5).and_return(nil)
      @service.update(5,nil)
    end

    it 'should return false if get returns nil' do
      @service.should_receive(:get).with(5).and_return(nil)
      @service.update(5,nil).should eq false
    end

    it 'should call update on record with correct params' do
      params = { :one => 'one', :two => 'two' }
      record = double('entity')
      @service.should_receive(:get).with(5)
      .and_return(record)
      record.should_receive(:update).with(params)
      .and_return(789)
      @service.update(5,params).should eq 789
    end
  end

  describe '#delete' do
    it 'should call get on service with correct id' do
      @service.should_receive(:get).with(5).and_return(nil)
      @service.delete(5)
    end

    it 'should return false if get returns nil' do
      @service.should_receive(:get).with(5).and_return(nil)
      @service.delete(5).should eq false
    end

    it 'should call delete on record' do
      record = double('entity')
      @service.should_receive(:get).with(5)
      .and_return(record)
      record.should_receive(:destroy).and_return(109)
      @service.delete(5).should eq 109
    end
  end

  describe '#set_user' do
    it 'should set user in service to param' do
      @service.set_user(nil)
      @service.user.should eq nil
    end

    it 'should not call set_user_scopes if user is nil' do
      @service.should_not_receive(:set_user_scopes)
      @service.set_user(nil)
      @service.user.should eq nil
    end

    it 'should call set_user_scopes if user is not' do
      user = { :scopes => [1,2] }
      @service.should_receive(:set_user_scopes).with([1,2])
      @service.set_user(user)
      @service.user.should eq user
    end
  end

  describe '#set_user_scopes' do
    it 'should set user_scopes in service to param' do
      @service.set_user_scopes(nil)
      @service.user_scopes.should eq nil

      @service.set_user_scopes(234234)
      @service.user_scopes.should eq 234234
    end
  end

  describe '#user_authorized_for?' do
    it 'should return true if scope_map is nil' do
      @service.scope_map = nil
      @service.user_authorized_for?(:one).should be true
    end

    it 'should return true if scope_map is not nil but no map for operation' do
      @service.scope_map = { :two => 'TWO' }
      @service.user_authorized_for?(:one).should be true
    end

    it 'should return false if user is nil' do
      @service.scope_map = { :two => 'TWO' }
      @service.user = nil
      @service.user_authorized_for?(:two).should be false
    end

    it 'should return false if user has nil scopes' do
      @service.scope_map = { :two => 'TWO' }
      @service.user = { :name => "Tom" }
      @service.user_scopes = nil
      @service.user_authorized_for?(:two).should be false
    end

    it 'should return false if user has empty scopes' do
      @service.scope_map = { :two => 'TWO' }
      @service.user = { :name => "Tom" }
      @service.user_scopes = []
      @service.user_authorized_for?(:two).should be false
    end

    it 'should return true if scope map exists in user scopes' do
      @service.scope_map = { :two => 'FIVE'}
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'FIVE']
      @service.user_authorized_for?(:two).should be true
    end

    it 'should return false if scope map does not exist in user scopes' do
      @service.scope_map = { :two => 'SEVEN'}
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'FIVE']
      @service.user_authorized_for?(:two).should be false
    end

    it 'should return true if scope map is array and shares one scope with user' do
      @service.scope_map = { :two => ['TWO'] }
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'THREE']
      @service.user_authorized_for?(:two).should be true
    end

    it 'should return true if scope map is array and shares more than one scope with user' do
      @service.scope_map = { :two => ['TWO','THREE'] }
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'THREE']
      @service.user_authorized_for?(:two).should be true
    end

    it 'should return false if scope map is array and does not share scopes with user' do
      @service.scope_map = { :two => ['FOUR'] }
      @service.user = { :name => "Tom" }
      @service.user_scopes = [ 'ONE', 'TWO', 'THREE']
      @service.user_authorized_for?(:two).should be false
    end
  end
end