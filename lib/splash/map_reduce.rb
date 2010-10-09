module Splash
  
  module MapReduce
    attr_reader :map, :reduce, :options
    
    module ClassMethods
      
      def from_callback(callback,map,reduce,options)
        thiz = self
        
        return Class.new do
          include Splash::HasAttributes
          include Splash::HasCollection
          
          extend thiz
          extend Splash::ActsAsScopeRoot
          extend_scoped! Splash::ActsAsScope::HashlikeAccess
          
          @callback, @map, @reduce, @options = callback.freeze, map.freeze, reduce.freeze, options.dup.freeze
        end
      end
      
      def from_scope(scope, map, reduce, options={})
        return scope.map_reduce(map, reduce, options)
      end
      
      alias_method :[],:from_scope
      
    end
    
    module Temporary
      
      include Splash::MapReduce
      extend Splash::MapReduce::ClassMethods
      
      
      def collection
        return generate_result
      end
      
      def default_options
        {:keeptemp => false}
      end
      
    end
    
    module Permanent
      
      include Splash::MapReduce
      
      def refresh!
        # certainly a thing that should be done in background
        generate_result
      end
      
    end
    
    protected
    
    def generate_result
      @callback.call(@map,@reduce,@options)
    end
    
    
  end
  
end