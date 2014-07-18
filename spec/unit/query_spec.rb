require "spec_helper"

describe JsonCrudApi::Query do
  describe '#initialize' do
    it 'should have correct defaults on nil query_string' do
      inst = JsonCrudApi::Query.new(nil)

      expect(inst).to be_kind_of JsonCrudApi::Query
      expect(inst.mode).to eq :default
      expect(inst.valid?).to be true
      expect(inst.errors).to eq []
      expect(inst.arguments).to eq []
      expect(inst.exclude_fields).to eq []
      expect(inst.include_fields).to eq []
      expect(inst.link_relations).to eq []
      expect(inst.filters).to eq []
      expect(inst.embed_relations).to eq []
    end

    it 'should have correct defaults on empty query_string' do
      inst = JsonCrudApi::Query.new('')

      expect(inst).to be_kind_of JsonCrudApi::Query
      expect(inst.mode).to eq :default
      expect(inst.valid?).to be true
      expect(inst.errors).to eq []
      expect(inst.arguments).to eq []
      expect(inst.include_fields).to eq []
      expect(inst.exclude_fields).to eq []
      expect(inst.link_relations).to eq []
      expect(inst.filters).to eq []
      expect(inst.embed_relations).to eq []
    end
  end

  describe '#valid?' do
    before do
      @inst = JsonCrudApi::Query.new('')
    end

    it 'should be equal to instance valid' do
      @inst.valid = true
      expect(@inst.valid?).to be true

      @inst.valid = false
      expect(@inst.valid?).to be false
    end
  end

  describe '#parse_from' do
    before do
      @inst = JsonCrudApi::Query.new('')
    end

    it 'should set valid? true and return immediately if str is nil' do
      expect(@inst).not_to receive(:arguments)
      expect(@inst.parse_from(nil))
      expect(@inst.valid?).to be true
    end

    it 'should set valid? true and return immediately if str is empty' do
      expect(@inst).not_to receive(:arguments)
      expect(@inst.parse_from(''))
      expect(@inst.valid?).to be true
    end

    it 'should set mode correctly for _include' do
      @inst.parse_from('_include=one')
      expect(@inst.mode).to eq :explicit
    end

    describe '_include' do
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
    end

    describe '_exclude' do
      it 'should list single field correctly for _exclude' do
        @inst.parse_from('_exclude=one')
        expect(@inst.exclude_fields).to eq([{:name=>'one',:path=>[]}])
      end

      it 'should list multiple field correctly for _exclude' do
        @inst.parse_from('_exclude=one,two')
        expect(@inst.exclude_fields).to eq([
          {:name=>'one',:path=>[]},
          {:name=>'two',:path=>[]}
        ])
      end
    end

    describe '_exclude and _include' do
      it 'should add error and set valid? false when both _include and _exclude specified' do
        @inst.parse_from('_exclude=one,two&_include=three')

        expect(@inst.valid?).to be false
        expect(@inst.errors).to eq([
          {
            :code=>:ambiguous_mode,
            :message=>"Ambiguous mode - do not set both _include and _exclude",
            :ref=>nil
          }
        ])
      end
    end

    describe '_link'do
      it 'should list single link relation' do
        @inst.parse_from('_link=five')
        expect(@inst.link_relations). to eq([{:name=>"five", :path=>[]}])
      end

      it 'should list single link relation with a path' do
        @inst.parse_from('_link=five.two')
        expect(@inst.link_relations). to eq([{:name=>"two", :path=>['five']}])
      end

      it 'should list multiple link relation' do
        @inst.parse_from('_link=one,six')
        expect(@inst.link_relations). to eq([{:name=>"one", :path=>[]}, {:name=>"six", :path=>[]}])
      end
    end

    describe "_embed" do
      it 'should list single embed relations' do
        @inst.parse_from('_embed=five')
        expect(@inst.embed_relations). to eq([{:name=>"five", :path=>[]}])
      end

      it 'should list single embed relation with a path' do
        @inst.parse_from('_embed=five.two')
        expect(@inst.embed_relations). to eq([{:name=>"two", :path=>['five']}])
      end

      it 'should list multiple embed relations' do
        @inst.parse_from('_embed=one,six')
        expect(@inst.embed_relations). to eq([{:name=>"one", :path=>[]}, {:name=>"six", :path=>[]}])
      end
    end

    describe 'query filter parameters' do
      it 'should add a single default equ filter' do
        @inst.parse_from('one=two')
        expect(@inst.filters).to eq([{:name=>'one',:operation=>:equ,:path=>[],:value=>'two'}])
      end

      it 'should add a single operation filter' do
        @inst.parse_from('one|neq=two')
        expect(@inst.filters).to eq([{:name=>'one',:operation=>:neq,:path=>[],:value=>'two'}])
      end

      it 'should add multiple default equ filters' do
        @inst.parse_from('one=two&three=four')
        expect(@inst.filters).to eq([
          {:name=>"one", :path=>[], :value=>"two", :operation=>:equ},
          {:name=>"three", :path=>[], :value=>"four", :operation=>:equ}
        ])
      end

      it 'should add multiple operation filters' do
        @inst.parse_from('one|neq=two&three|like=four')
        expect(@inst.filters).to eq([
          {:name=>"one", :path=>[], :value=>"two", :operation=>:neq},
          {:name=>"three", :path=>[], :value=>"four", :operation=>:like}
        ])
      end

      it 'should set valid? false on bad operation' do
        @inst.parse_from('one|truck=two')

        expect(@inst.valid?).to be false
        expect(@inst.errors).to eq [{:code=>:unknown_operation, :message=>"Unknown Operation \"truck\"", :ref=>"one|truck"}]      end
    end
  end

  describe '#set_mode_and_fields' do
    before do
      @inst = JsonCrudApi::Query.new(nil)
    end

    it 'should set mode properly' do
      @inst.send(:set_mode_and_fields, :explicit, [])

      expect(@inst.valid?).to be true
      expect(@inst.mode).to eq :explicit
    end

    it 'should add error and set valid? = false on ambiguous_mode' do
      @inst.send(:set_mode_and_fields, :explicit, [])
      @inst.send(:set_mode_and_fields, :implicit, [])

      expect(@inst.valid?).to be false
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

  describe '#set_relations' do
    before do
      @inst = JsonCrudApi::Query.new(nil)
    end

    it 'should not yield when empty' do
      out = []
      @inst.send(:set_relations, []) do |field|
        out << field
      end

      expect(out).to eq []
    end

    it 'should yield single relation' do
      out = []
      @inst.send(:set_relations, ['one']) do |field|
        out << field
      end

      expect(out).to eq [{:name=>"one", :path=>[]}]
    end

    it 'should yield multiple relations' do
      out = []
      @inst.send(:set_relations, ['one','two.three']) do |field|
        out << field
      end

      expect(out).to eq [{:name=>"one", :path=>[]}, {:name=>"three", :path=>["two"]}]
    end
  end

  describe '#parse_operation' do
    before do
      @inst = JsonCrudApi::Query.new(nil)
    end

    it 'should generate correct filter for single default arg' do
      ob = @inst.send(:parse_operation,'one','two')
      expect(ob).to eq({ :name=>'one', :path => [], :operation=>:equ, :value=>'two'})
    end

    it 'should generate correct filter for default arg with path' do
      ob = @inst.send(:parse_operation,'two.one','three')
      expect(ob).to eq({ :name=>'one', :path => ['two'], :operation=>:equ, :value=>'three'})
    end

    it 'should generate correct filter for arg with equ' do
      ob = @inst.send(:parse_operation,'one|equ','two')
      expect(ob).to eq({:name=>"one", :path=>[], :value=>"two", :operation=>:equ})
    end

    it 'should generate correct filter for arg with other operation (lte)' do
      ob = @inst.send(:parse_operation,'one|lte','two')
      expect(ob).to eq({:name=>"one", :path=>[], :value=>"two", :operation=>:lte})
    end

    it 'should return nil, set valid? false and add error if operation is unknown' do
      ob = @inst.send(:parse_operation,'one|truck','two')
      expect(ob).to be nil

      expect(@inst.valid?).to be false
      expect(@inst.errors).to eq [{:code=>:unknown_operation, :message=>"Unknown Operation \"truck\"", :ref=>"one|truck"}]
    end
  end

  describe '#map_operation' do
    it 'should return nil if operation is nil' do
      ob = JsonCrudApi::Query.send(:map_operation,nil)
      expect(ob).to be nil
    end

    it 'should return nil if operation is empty' do
      ob = JsonCrudApi::Query.send(:map_operation,'')
      expect(ob).to be nil
    end

    it 'should return :equ if operation is "equ"' do
      ob = JsonCrudApi::Query.send(:map_operation,'equ')
      expect(ob).to be :equ
    end

    it 'should return :neq if operation is "neq"' do
      ob = JsonCrudApi::Query.send(:map_operation,'neq')
      expect(ob).to be :neq
    end

    it 'should return :gt if operation is "gt"' do
      ob = JsonCrudApi::Query.send(:map_operation,'gt')
      expect(ob).to be :gt
    end

    it 'should return :lt if operation is "lt"' do
      ob = JsonCrudApi::Query.send(:map_operation,'lt')
      expect(ob).to be :lt
    end

    it 'should return :gte if operation is "gte"' do
      ob = JsonCrudApi::Query.send(:map_operation,'gte')
      expect(ob).to be :gte
    end

    it 'should return :lte if operation is "lte"' do
      ob = JsonCrudApi::Query.send(:map_operation,'lte')
      expect(ob).to be :lte
    end

    it 'should return :like if operation is "like"' do
      ob = JsonCrudApi::Query.send(:map_operation,'like')
      expect(ob).to be :like
    end

    it 'should return :notlike if operation is "notlike"' do
      ob = JsonCrudApi::Query.send(:map_operation,'notlike')
      expect(ob).to be :notlike
    end

    it 'should return nil if operation is unknwon' do
      ob = JsonCrudApi::Query.send(:map_operation,'bad_operation')
      expect(ob).to be nil
    end
  end

  describe '#parse_field' do
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

    it 'should set valid? to false' do
      @inst.send(:add_error,'one','two','three')

      expect(@inst.valid?).to be false
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