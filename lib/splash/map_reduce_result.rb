# -*- encoding : utf-8 -*-
module Splash
  module MapReduceResult
    
    module OneTimeCollection
      
      def find(*args)
        result = super(*args)
        def self.find(*args)
          raise "Trying to requery a temporary collection."
        end
        return result
      end
      
    end
    
    def self.from_result(ns, res)
      
      col = ns.collection(res['result'])
      
      col.extend(OneTimeCollection)
      
      c = Class.new do
        
        include MapReduceResult
        
        namespace ns
        collection col
        
      end
      
      return c
      
    end
    
    include Splash::Saveable
    include Splash::HasAttributes
    include Splash::HasCollection
    
    extend Splash::ActsAsScopeRoot
    
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
          #include Splash::ActsAsCollection.of(base)
          extend Splash::ActsAsScopeRoot
          
          def included(base)
            Splash::Document.included(base)
            super(base)
          end
          
          def persister
            Splash::Document::Persister.new(self.namespace)
          end
          
          extend_scoped! Splash::ActsAsScope::HashlikeAccess
          
        end
      end
    end
    
    def initialize(attr={})
      self.attributes.load(attr)
    end
    
  end
end
