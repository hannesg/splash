# -*- encoding : utf-8 -*-
module Splash::Document
  
  class Persister
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
    
    def initialize(ns,klass = Object )
      @namespace, @class = ns, klass
    end
  end
  
  class ByIdPersister < Persister
    
    def to_saveable(value)
      return nil if value.nil?
      return value._id
    end
    
  end
  
  class ByIdStringPersister < Persister
    
    def to_saveable(value)
      return nil if value.nil?
      return value._id.to_s
    end
    
  end
  
  
  include Splash::Saveable
  include Splash::HasAttributes
  include Splash::HasCollection
  include Splash::Callbacks
  
  with_callbacks! :store!
  
  #include Splash::Validates
  
  class << self
    def included(base)
      
      included_modules.each do |mod|
        begin
          mod.included(base)
        rescue NoMethodError
        end
      end
      
      super(base)
      
      base.instance_eval do
        extend Splash::ActsAsScopeRoot
        
        def included(base)
          Splash::Document.included(base)
          super(base)
        end
        
        def persister(strategy=nil)
          if strategy == :by_id
            return Splash::Document::ByIdPersister.new(self.namespace,self)
          elsif strategy == :by_id_string
            return Splash::Document::ByIdStringPersister.new(self.namespace,self)
          end
          Splash::Document::Persister.new(self.namespace,self)
        end
        
        extend_scoped! Splash::ActsAsScope::ArraylikeAccess
        
      end
    end
  end
  
end
