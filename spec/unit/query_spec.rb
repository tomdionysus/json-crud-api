require "spec_helper"

describe JsonCrudApi::Query do
  describe '#initialize' do
    it 'should have correct defaults on nil query_string' do
      inst = JsonCrudApi::Query.new(nil)

      expect(inst).to be_kind_of JsonCrudApi::Query
      expect(inst.mode).to eq :default
      expect(inst.valid).to be true
      expect(inst.errors).to eq []
      expect(inst.arguments).to eq []
      expect(inst.exclude_fields).to eq []
      expect(inst.include_fields).to eq []
    end

    it 'should have correct defaults on empty query_string' do
      inst = JsonCrudApi::Query.new('')

      expect(inst).to be_kind_of JsonCrudApi::Query
      expect(inst.mode).to eq :default
      expect(inst.valid).to be true
      expect(inst.errors).to eq []
      expect(inst.arguments).to eq []
      expect(inst.include_fields).to eq []
      expect(inst.exclude_fields).to eq []
    end
  end

  describe '#parse_from' do
    before do
      @inst = JsonCrudApi::Query.new('')
    end

    it 'should return immediately if str is nil' do
      expect(@inst).not_to receive(:arguments)
      expect(@inst.parse_from(nil))
    end

    it 'should return immediately if str is empty' do
      expect(@inst).not_to receive(:arguments)
      expect(@inst.parse_from(''))
    end

    it 'should set mode correctly for _include' do
      @inst.parse_from('_include=one')
      expect(@inst.mode).to eq :explicit
    end

    it 'should list single field correctly for _include' do
      @inst.parse_from('_include=one')
      expect(@inst.include_fields).to eq([{:name=>'one',:path=>[]}])
    end

    it 'should list multiple fields correctly for _include' do
      @inst.parse_from('_include=one,two')
      expect(@inst.include_fields).to eq([
        {:name=>'one',:path=>[]},
        {:name=>'two',:path=>[]}
      ])
    end

    it 'should list single field correctly for _exclude' do
      @inst.parse_from('_exclude=one,two')
      expect(@inst.exclude_fields).to eq([
        {:name=>'one',:path=>[]},
        {:name=>'two',:path=>[]}
      ])
    end
  end

  describe '#set_mode_and_fields' do
    before do
      @inst = JsonCrudApi::Query.new(nil)
    end

    it 'should set mode properly' do
      @inst.send(:set_mode_and_fields, :explicit, [])

      expect(@inst.valid).to be true
      expect(@inst.mode).to eq :explicit
    end

    it 'should add error and set valid = false on ambiguous_mode' do
      @inst.send(:set_mode_and_fields, :explicit, [])
      @inst.send(:set_mode_and_fields, :implicit, [])

      expect(@inst.valid).to be false
    end

    it 'should yield single field' do

      out = []
      @inst.send(:set_mode_and_fields, :explicit, ['one']) do |field|
        out << field
      end

      expect(out).to eq [{:name=>"one", :path=>[]}]
    end

    it 'should yield multiple fields' do

      out = []
      @inst.send(:set_mode_and_fields, :explicit, ['one','two.three']) do |field|
        out << field
      end

      expect(out).to eq [
        {:name=>"one", :path=>[]}, {:name=>"three", :path=>["two"]}
      ]
    end
  end

  describe '#parse_field' do
    before do
      @inst = JsonCrudApi::Query.new(nil)
    end

    it 'should handle a single field name with no path' do
      ob = JsonCrudApi::Query.send(:parse_field,'one')
      expect(ob).to eq({ :name=>'one', :path => []})
    end

    it 'should handle a field name with path' do
      ob = JsonCrudApi::Query.send(:parse_field,'two.one')
      expect(ob).to eq({ :name=>'one', :path => ['two']})
    end

    it 'should handle complex path' do
      ob = JsonCrudApi::Query.send(:parse_field,'two.one.three.four')
      expect(ob).to eq({ :name=>'four', :path => ['two','one','three']})
    end
  end

  describe '#add_error' do
    before do
      @inst = JsonCrudApi::Query.new(nil)
    end

    it 'should set valid to false' do
      @inst.send(:add_error,'one','two','three')

      expect(@inst.valid).to be false
    end

    it 'should add correct error' do
      @inst.send(:add_error,'one','two','three')

      expect(@inst.errors).to eq [ { :code => 'one', :message => 'two', :ref => 'three' } ]
    end

    it 'should add correct error when errors already exist' do
      @inst.send(:add_error,'one','two','three')
      @inst.send(:add_error,'four','five','six')

      expect(@inst.errors).to eq [
        { :code => 'one', :message => 'two', :ref => 'three' },
        { :code => 'four', :message => 'five', :ref => 'six' }
      ]
    end

    it 'should default ref to nil if not supplied' do
      @inst.send(:add_error,'one','two')

      expect(@inst.errors).to eq [ { :code => 'one', :message => 'two', :ref => nil } ]
    end
  end
end