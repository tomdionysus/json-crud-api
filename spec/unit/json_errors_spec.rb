require "spec_helper"

describe JsonCrudApi::JsonErrors do

  before do
    class TestClass
      include JsonCrudApi::JsonErrors

      attr_accessor :errors

      def env
        @test_env
      end
    end

    @test = TestClass.new
  end

  describe '#clear_errors' do
    it 'should set @errors to []' do

      @test.errors = 9123878123
      @test.clear_errors

      expect(@test.errors).to eq []
    end
  end

  describe '#add_error' do
    it 'should initialise @errors if not set' do
      @test.errors = nil
      @test.add_error(1,2)

      expect(@test.errors).not_to be nil
    end

    it 'should add an error with correct structure' do
      @test.add_error(1,2)

      expect(@test.errors).to eq([{ :code =>1, :message =>2}])
    end

    it 'should add an error with a reference if specified' do
      @test.add_error(1,2,3)

      expect(@test.errors).to eq([{ :code =>1, :message =>2 ,:reference =>3}])
    end

    it 'should add multiple errors' do
      @test.add_error(1,2,3)
      @test.add_error(4,5,6)

      expect(@test.errors).to eq([
        { :code =>1, :message =>2 ,:reference =>3},
        { :code =>4, :message =>5 ,:reference =>6}
      ])
    end
  end

  describe '#fail_with_error' do
    it 'should call add_error and fail_with_errors correctly' do
      expect(@test).to receive(:add_error).with(2,3,4)
      expect(@test).to receive(:fail_with_errors).with(422)

      @test.fail_with_error(422,2,3,4)
    end

    it 'should respect existing errors' do
      @test.add_error(1,2,3)

      expect(@test).to receive(:fail_with_errors).with(422)

      @test.fail_with_error(422,2,3,4)

      expect(@test.errors).to eq([
        { :code =>1, :message =>2 ,:reference =>3},
        { :code =>2, :message =>3 ,:reference =>4}
      ])
    end
  end

  describe '#fail_with_errors' do
    it 'should call halt with correct status and JSON' do
      @test.errors = { :one =>1, :two =>2 }

      expect(@test).to receive(:halt).with(504, '{"success":false,"errors":{"one":1,"two":2}}')

      @test.fail_with_errors(504)
    end

    it 'should call halt with default 422 status and JSON' do
      @test.errors = { :one =>1, :two =>2 }

      expect(@test).to receive(:halt).with(422, '{"success":false,"errors":{"one":1,"two":2}}')

      @test.fail_with_errors
    end
  end

  describe '#fail_not_found' do
    it 'should call fail_not_found with 404 and message' do
      expect(@test).to receive(:fail_with_error).with(404, 'NOT_FOUND','The resource cannot be found.')
      @test.fail_not_found
    end
  end

  describe '#fail_unauthorized' do
    it 'should call fail_not_found with 404 and message' do
      expect(@test).to receive(:fail_with_error).with(401, 'UNAUTHORIZED','Authorization is required to perform this operation on the resource.')
      @test.fail_unauthorized
    end
  end

  describe '#fail_forbidden' do
    it 'should call fail_not_found with 404 and message' do
      expect(@test).to receive(:fail_with_error).with(403, 'FORBIDDEN','The user is not allowed to perform this operation on the resource.')
      @test.fail_forbidden
    end
  end

  # TODO: Moar Specs!
end
