class AttrAccessorObject
  def self.my_attr_reader(*ivars)
    ivars.each do |ivar|
      define_method("#{ivar}") do
        instance_variable_get("@#{ivar}")
      end
    end
  end

  def self.my_attr_writer(*ivars)
    ivars.each do |ivar|
      define_method("#{ivar}=") do |arg|
        instance_variable_set("@#{ivar}", arg)
      end
    end
  end

  def self.my_attr_accessor(*ivars)
    my_attr_reader(*ivars)
    my_attr_writer(*ivars)
  end
end
