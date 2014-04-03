require "helper"

describe JsonCrudApi::Service do
  before(:each) do
    @mock_repo = double('repo')
    @mock_log = double('Log')

    @service = JsonCrudApi::Service.new({
      :log_service => @mock_log,
      :repository => @mock_repo
    })
  end

  describe '#initialize' do
    it 'should inject dependencies correctly' do
      @service.log_service.should eq @mock_log
      @service.repo.should eq @mock_repo
    end
  end
end