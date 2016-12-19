require 'attr_accessor_object'

describe AttrAccessorObject do
  before(:all) do
    class TestAttrAccessorObject < AttrAccessorObject
      my_attr_reader :a, :b
      my_attr_writer :j, :k
      my_attr_accessor :x, :y
    end
  end

  after(:all) do
    Object.send(:remove_const, :TestAttrAccessorObject)
  end

  subject(:obj) { TestAttrAccessorObject.new }

  describe '#my_attr_reader' do
    it 'defines getter methods' do
      expect(obj).to respond_to(:a)
      expect(obj).to respond_to(:b)
    end

    it 'does not define setter methods' do
      expect { obj.a = '@a value' }.to raise_error(NoMethodError)
      expect { obj.b = '@b value' }.to raise_error(NoMethodError)
    end
  end

  describe '#my_attr_writer' do
    it 'defines setter methods' do
      expect(obj).to respond_to(:j=)
      expect(obj).to respond_to(:k=)
    end

    it 'does not define getter methods' do
      expect { obj.j }.to raise_error(NoMethodError)
      expect { obj.k }.to raise_error(NoMethodError)
    end
  end

  describe '#my_attr_accessor' do
    it 'defines getter methods' do
      expect(obj).to respond_to(:x)
      expect(obj).to respond_to(:y)
    end

    it 'defines setter methods' do
      expect(obj).to respond_to(:x=)
      expect(obj).to respond_to(:y=)
    end

    it 'getter methods get from associated ivars' do
      x_val = '@x value'
      y_val = '@y value'
      obj.instance_variable_set('@x', x_val)
      obj.instance_variable_set('@y', y_val)

      expect(obj.x).to eq(x_val)
      expect(obj.y).to eq(y_val)
    end

    it 'setter methods set associated ivars' do
      x_val = '@x value'
      y_val = '@y value'
      obj.x = x_val
      obj.y = y_val

      expect(obj.instance_variable_get('@x')).to eq(x_val)
      expect(obj.instance_variable_get('@y')).to eq(y_val)
    end
  end
end
