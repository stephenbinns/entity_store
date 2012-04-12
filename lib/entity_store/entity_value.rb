module EntityStore
  module EntityValue
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
      end
    end
    
    def initialize(attr={})
      attr.each_pair { |k,v| self.send("#{k}=", v) }
    end
    
    def attributes
      Hash[*public_methods.select {|m| m =~ /\w\=$/}.collect do |m|
        attribute_name = m.to_s.chop.to_sym
        [attribute_name, send(attribute_name).respond_to?(:attributes) ? send(attribute_name).attributes : send(attribute_name)]
      end.flatten]
    end
    
    module ClassMethods
      def entity_value_attribute(name, klass)
        define_method(name) { instance_variable_get("@#{name}") }
        define_method("#{name}=") do |value|
          instance_variable_set("@#{name}", value.is_a?(Hash) ? klass.new(value) : value)
        end
      end
    end
  end
end