# -*- encoding : utf-8 -*-
module Splash
  class MapReduceResult
    
    module OneTimeCollection
      
      def find(*args)
        result = super(*args)
        def self.find(*args)
          raise "Trying to requery a temporary collection."
        end
        return result
      end
      
    end
    
    attr_accessor :collection
    
    include Splash::ActsAsScopeRoot
    
    def initialize(collection)
      @collection = collection
      @collection.extend(OneTimeCollection)
    end
    
    def from_saveable(data)
      AttributedStruct.new(data)
    end
    
    def [](key)
      conditions('_id'=>key).next_document.value
    end
    
  end
end
