module Splash

module EmbededDocument

  class Persister < Document::Persister
  
    def to_saveable(value)
      return nil if value.nil?
      return BSON::DBRef.new( value.class.collection.name , value._id )
    end
    
    def from_saveable(value)
      return nil if value.nil?
      
      if value.kind_of? BSON::DBRef
        found_class = @namespace.class_for(value.namespace)
        unless found_class <= @class
          warn "Trying to fetch an object of type #{found_class} from #{@class}."
          return nil
        end
        return found_class.conditions('_id'=>value.object_id).first
      elsif value.kind_of? BSON::ObjectId
        return @class.conditions('_id' => value).first
      elsif value.kind_of? String
        return @class.conditions('_id' => BSON::ObjectId.from_string(value) ).first
      end
      raise "No idea how to fetch #{value}."
    end
  
  end

  extend Cautious

  include Document
  
  module ClassMethods
  
    def persister( strategy = :embed)
    
    
    end
  
  end



end


end
