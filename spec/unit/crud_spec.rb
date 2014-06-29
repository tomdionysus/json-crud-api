require "spec_helper"

describe JsonCrudApi::AuthClient do
  before(:each) do
    class CrudTest 
      include JsonCrudApi::Crud
    end

    @test = CrudTest.new
  end

  describe '#crud_api' do
    it 'should enable get_all if configured' do
      expect(@test).to receive(:get).with('/test')

      expect(@test).not_to receive(:get)
      expect(@test).not_to receive(:post)
      expect(@test).not_to receive(:put)
      expect(@test).not_to receive(:delete)

      @test.crud_api('/test',:one, [:disable_write,:disable_get])
    end

    it 'should enable get if configured' do
      expect(@test).to receive(:get).with('/test/:id')

      expect(@test).not_to receive(:get).with('/test')
      expect(@test).not_to receive(:post)
      expect(@test).not_to receive(:put)
      expect(@test).not_to receive(:delete)

      @test.crud_api('/test',:one, [:disable_write,:disable_get_all])
    end

    it 'should enable post if configured' do
      expect(@test).to receive(:post).with('/test')

      expect(@test).not_to receive(:get)
      expect(@test).not_to receive(:post)
      expect(@test).not_to receive(:put)
      expect(@test).not_to receive(:delete)

      @test.crud_api('/test',:one, [:disable_put,:disable_delete,:disable_read])
    end

    it 'should enable put if configured' do
      expect(@test).to receive(:put).with('/test/:id')

      expect(@test).not_to receive(:get)
      expect(@test).not_to receive(:post)
      expect(@test).not_to receive(:delete)

      @test.crud_api('/test',:one, [:disable_post,:disable_delete,:disable_read])
    end

    it 'should enable delete if configured' do
      expect(@test).to receive(:delete).with('/test/:id')

      expect(@test).not_to receive(:get)
      expect(@test).not_to receive(:post)
      expect(@test).not_to receive(:put)

      @test.crud_api('/test',:one, [:disable_post,:disable_put,:disable_read])
    end

  end
end