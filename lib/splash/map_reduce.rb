module Splash
  
  module MapReduce
    
    class Result
      include Splash::Document
    end
    
    def map
      return @__map_reduce_options[:map]
    end
    
    def reduce
      return @__map_reduce_options[:reduce]
    end
    
    def map_reduce_callback
      return @__map_reduce_options[:callback]
    end
    
    private :map_reduce_callback
    
    module ClassMethods
      
      def from_callback(callback,map,reduce,options,&block)
        thiz = self
        
        map = BSON::Code.new(map) if map.kind_of? String
        reduce = BSON::Code.new(reduce) if reduce.kind_of? String
        
        c = Class.new(Result) do
          
          @__map_reduce_options = {
            :callback => callback.freeze,
            :map => map.freeze,
            :reduce => reduce.freeze,
            :options => options.dup.freeze
          }.freeze
          
          extend thiz
          
        end
        if block_given?
          c.class_eval &block
        end
        m = c.map rescue nil
        unless m.kind_of?(String) or m.kind_of?(BSON::Code)
          raise ArgumentError,"String or BSON::Code expected, got #{m.inspect}. Please provide a map function or define a method called 'map'."
        end
        r = c.reduce rescue nil
        unless r.kind_of?(String) or r.kind_of?(BSON::Code)
          raise ArgumentError,"String or BSON::Code expected, got #{r.inspect}. Please provide a reduce function or define a method called 'reduce'."
        end
        return c
      end
      
    end
    
    def self.[](scope, map="", reduce="", options={},&block)
      return scope.map_reduce(map, reduce, options.merge(:keeptemp => true),&block)
    end
    
    module Temporary
      
      include Splash::MapReduce
      extend Splash::MapReduce::ClassMethods
      
      
      def collection
        refresh!
        super
      end
      
      def map_reduce_options
        options = @__map_reduce_options[:options].dup
        options[:keeptemp] = false
        options[:raw] = true
        options[:out] = nil
        return options
      end
      
    end
    
    module Permanent
      
      include Splash::MapReduce
      extend Splash::MapReduce::ClassMethods
      
      def map_reduce_options
        options = @__map_reduce_options[:options].dup
        options[:keeptemp] = true
        options[:raw] = true
        options[:out] = self.collection.name
        return options
      end
      
    end
    
    def refresh!
      result = map_reduce_callback.call(map,reduce,map_reduce_options)
      self.collection = self.namespace.collection(result["result"])
      return result.except(["result","ok"])
    end
    
    
  end
  
end