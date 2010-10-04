# -*- encoding : utf-8 -*-
module Splash::Document
  
  class Persister
    def to_saveable(value)
      return nil if value.nil?
      return BSON::DBRef.new( value.class.collection.name , value._id )
    end
    
    def from_saveable(value)
      return nil if value.nil?
      return @namespace.dereference(value)
    end
    
    def initialize(ns)
      @namespace = ns
    end
  end
  
  
  include Splash::Saveable
  include Splash::HasAttributes
  include Splash::Validates
  
  class << self
    def included(base)
      included_modules.each do |mod|
        mod.included(base)
      end
      
      base.instance_eval do
        #include Splash::ActsAsCollection.of(base)
        extend Splash::ActsAsScopeRoot
        
        def included(base)
          Splash::Document.included(base)
          super(base)
        end
        
        def persister
          Splash::Document::Persister.new(self.namespace)
        end
        
        extend_scoped! Splash::ActsAsScope::ArraylikeAccess
        
      end
    end
  end
  
  def initialize(args={})
    self.attributes.load(args)
  end
  
  def to_saveable
    attributes.raw
  end
  
end
