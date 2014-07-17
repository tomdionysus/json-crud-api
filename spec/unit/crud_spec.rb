require "spec_helper"

describe JsonCrudApi::Crud do
  before(:each) do
    @test_user = { :name=>"Test User", :scopes => ['ADMIN'] }

    class CrudTest
      attr_accessor :test_settings, :test_params, :payload, :user
      include JsonCrudApi::Crud

      def settings
        @test_settings
      end

      def params
        @test_params
      end
    end

    @test = CrudTest.new
    @test.user = @test_user
    @test.test_params = {}

  end

  describe '#crud_get_all' do

    before do
      @service = double('service')
      @presenter = double('presenter')

      @test.test_settings = OpenStruct.new({
        :services=>OpenStruct.new,
        :presenters=>OpenStruct.new
      })

    end

    it 'should call get_all on service, render on the presenter, and return JSON' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :get_all).and_return(true)
      expect(@service).to receive(:get_all).and_return([])

      expect(@presenter).to receive(:render).with([], :get_all).and_return({ :test_output => 1})

      expect(@test.send(:crud_get_all,'thekey')).to eq '{"test_output":1}'
    end

    it 'should fail_forbidden if not authorized for get_all' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :get_all).and_return(false)

      expect(@test).to receive(:fail_forbidden)

      expect(@service).not_to receive(:get_all)
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_get_all,'thekey')
    end

    it 'should fail_not_found if service returned nil' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :get_all).and_return(true)
      expect(@service).to receive(:get_all).and_return(nil)

      expect(@test).to receive(:fail_not_found)

      expect(@service).not_to receive(:get_all)
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_get_all,'thekey')
    end
  end

  describe '#crud_get' do
    before do
      @service = double('service')
      @presenter = double('presenter')

      @test.test_settings = OpenStruct.new({
        :services=>OpenStruct.new,
        :presenters=>OpenStruct.new
      })
      @test.test_params = { "id" => 234 }
    end

    it 'should call get on service, render on the presenter, and return JSON' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :get).and_return(true)
      expect(@service).to receive(:get).with(234).and_return([])

      expect(@presenter).to receive(:render).with([], :get).and_return({ :test_output => 56})

      expect(@test.send(:crud_get,'thekey')).to eq '{"test_output":56}'
    end

    it 'should fail_forbidden if not authorized for get' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :get).and_return(false)

      expect(@test).to receive(:fail_forbidden)

      expect(@service).not_to receive(:get)
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_get,'thekey')
    end

    it 'should fail_not_found if service returned nil' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :get).and_return(true)
      expect(@service).to receive(:get).with(234).and_return(nil)

      expect(@test).to receive(:fail_not_found)

      expect(@service).not_to receive(:get)
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_get,'thekey')
    end
  end

  describe '#crud_post' do
    before do
      @service = double('service')
      @presenter = double('presenter')

      @test.test_settings = OpenStruct.new({
        :services=>OpenStruct.new,
        :presenters=>OpenStruct.new
      })
      @test.payload = { :test_payload_int => 12313 }
    end

    it 'should call create on service, parse on the presenter, render on the presenter, and return JSON' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :create).and_return(true)
      expect(@service).to receive(:valid_for?).with({ :test_output => 12398}, :create, @test).and_return(true)
      expect(@service).to receive(:create).with({ :test_output => 12398}).and_return({ :test_output => 77234})

      expect(@presenter).to receive(:parse).with(@test.payload, :post).and_return({ :test_output => 12398})
      expect(@presenter).to receive(:render).with({ :test_output => 77234}, :post).and_return({ :test_output => 12313})

      expect(@test.send(:crud_post,'thekey')).to eq '{"test_output":12313}'
    end

    it 'should fail with 422 if service valid_for? fails' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :create).and_return(true)
      expect(@service).to receive(:valid_for?).with({ :test_output => 12398}, :create, @test).and_return(false)

      expect(@presenter).to receive(:parse).with(@test.payload, :post).and_return({ :test_output => 12398})

      expect(@test).to receive(:fail_with_errors)

      expect(@service).not_to receive(:create)
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_post,'thekey')
    end

    it 'should fail_forbidden if not authorized for create' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :create).and_return(false)

      expect(@test).to receive(:fail_forbidden)

      expect(@service).not_to receive(:create)
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_post,'thekey')
    end
  end

  describe '#crud_put' do
    before do
      @service = double('service')
      @presenter = double('presenter')

      @test.test_settings = OpenStruct.new({
        :services=>OpenStruct.new,
        :presenters=>OpenStruct.new
      })
      @test.test_params = { "id" => 7345 }
      @test.payload = { :test_payload_int => 12313 }
    end

    it 'should call update on service, get on the service, parse on the presenter, render on the presenter, and return JSON' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :update).and_return(true)
      expect(@presenter).to receive(:parse).with(@test.payload, :put).and_return({ :test_output => 12398})
      expect(@service).to receive(:valid_for?).with({ :test_output => 12398},:update,@test).and_return(true)
      expect(@service).to receive(:update).with(7345, { :test_output => 12398}).and_return(true)
      expect(@service).to receive(:get).with(7345).and_return({ :test_output => 77234})

      expect(@presenter).to receive(:render).with({ :test_output => 77234}, :put).and_return({ :test_output => 12313})

      expect(@test.send(:crud_put,'thekey')).to eq '{"test_output":12313}'
    end

    it 'should fail_with_errors if service valid_for? fails' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :update).and_return(true)
      expect(@presenter).to receive(:parse).with(@test.payload, :put).and_return({ :test_output => 12398})
      expect(@service).to receive(:valid_for?).with({ :test_output => 12398},:update,@test).and_return(false)
      expect(@presenter).not_to receive(:render)

      expect(@test).to receive(:fail_with_errors)

      expect(@test.send(:crud_put,'thekey'))
    end

    it 'should fail_not_found if service update returned false' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :update).and_return(true)
      expect(@service).to receive(:valid_for?).with({ :test_output => 12398},:update,@test).and_return(true)
      expect(@service).to receive(:update).with(7345, { :test_output => 12398}).and_return(false)

      expect(@test).to receive(:fail_not_found)

      expect(@presenter).to receive(:parse).with(@test.payload, :put).and_return({ :test_output => 12398})
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_put,'thekey')
    end

    it 'should fail_forbidden if not authorized for update' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :update).and_return(false)

      expect(@test).to receive(:fail_forbidden)

      expect(@service).not_to receive(:update)
      expect(@service).not_to receive(:get)
      expect(@presenter).not_to receive(:render)

      @test.send(:crud_put,'thekey')
    end
  end

  describe '#crud_delete' do
    before do
      @service = double('service')
      @presenter = double('presenter')

      @test.test_settings = OpenStruct.new({
        :services=>OpenStruct.new,
        :presenters=>OpenStruct.new
      })
      @test.test_params = { "id" => 234 }
    end

    it 'should call delete on service and return 204' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :delete).and_return(true)
      expect(@service).to receive(:delete).with(234).and_return(true)

      expect(@test.send(:crud_delete,'thekey')).to eq 204
    end

    it 'should fail_forbidden if not authorized for delete' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :delete).and_return(false)

      expect(@test).to receive(:fail_forbidden)

      expect(@service).not_to receive(:delete)

      @test.send(:crud_delete,'thekey')
    end

    it 'should fail_not_found if service delete returned false' do
      expect(@test.test_settings.services).to receive(:[]).with('thekey').and_return(@service)
      expect(@test.test_settings.presenters).to receive(:[]).with('thekey').and_return(@presenter)

      expect(@service).to receive(:user_authorized_for?).with(@test_user, :delete).and_return(true)
      expect(@service).to receive(:delete).with(234).and_return(false)

      expect(@test).to receive(:fail_not_found)

      @test.send(:crud_delete,'thekey')
    end

  end

  describe '#multiple_ids?' do
    it 'should return false for a singular param id' do
      @test.test_params["id"] = "123"

      expect(@test.send(:multiple_ids?)).to be false
    end

    it 'should return true for multiple param ids' do
      @test.test_params["id"] = "12,882"

      expect(@test.send(:multiple_ids?)).to be true
    end

    it 'should return true for range param ids' do
      @test.test_params["id"] = "[1..10]"

      expect(@test.send(:multiple_ids?)).to be true
    end

    it 'should return true for mixed range param ids' do
      @test.test_params["id"] = "5,6,[1..10]"

      expect(@test.send(:multiple_ids?)).to be true
    end
  end

  describe '#parse_ids' do
    it 'should return correctly for a singular param id' do
      @test.test_params["id"] = "123"

      expect(@test.send(:parse_ids)).to eq ["123"]
    end

    it 'should return correctly for multiple param ids' do
      @test.test_params["id"] = "12,882"

      expect(@test.send(:parse_ids)).to eq ["12","882"]
    end
  end
end