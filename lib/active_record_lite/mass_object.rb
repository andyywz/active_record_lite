class MassObject
  def initialize(params = {})
    # self here is an instance of a class so we have to use self.class to call the actual subclass
    params.each do |attr_name, attr_value|
      if self.class.attributes.include?(attr_name.to_sym)
        self.send("#{attr_name}=", attr_value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end

  def self.set_attrs(*attributes)
    @attributes = []
    attributes.each do |attribute|
      self.send("attr_accessor", attribute)
      @attributes << attribute
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
  end
end

class MyClass < MassObject
  set_attrs :x, :y
end

MyClass.new(:x => :x_val, :y => :y_val)
