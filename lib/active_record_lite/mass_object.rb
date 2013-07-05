class MassObject
  def initialize(params = {})
    params.each do |attr_name, attr_value|
      if self.class.attributes.include?(attr_name)
        self.class.send("#{attr_name}=".to_sym, attr_value)
      else
        raise "mass assignment to unregistered attribute #{attr_name}"
      end
    end
  end

  def self.set_attrs(*attributes)
    @attributes = []
    attributes.each do |attribute|
      self.class.send("attr_accessor", attribute)
      p attribute
      @attributes << attribute
    end
  end

  def self.attributes
    @attributes
  end

  def self.parse_all(results)
  end
end

=begin
class MyClass < MassObject
  set_attrs :x, :y
end

MyClass.new(:x => :x_val, :y => :y_val)
=end