# InheritableAttributes
module InheritableAttributes
  module ClassMethods
    def inherit_attributes(attributes, options = {})
      raise ArgumentError.new("must specify :from") unless options[:from]
      parent = options[:from]
      [attributes].flatten.each do |attribute|
        parent_attribute = options[:as] || attribute
        fn = <<-EOV
          def #{attribute}_with_inheritance
            val = #{attribute}_without_inheritance
            
            (val.blank? && ! parent.nil?) ? #{parent}.#{parent_attribute} : val
          end
          alias_method_chain :#{attribute}, :inheritance
        EOV
        class_eval fn
      end
    end
    
    alias inherit_attribute inherit_attributes
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
  end
end