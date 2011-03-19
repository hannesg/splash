# -*- encoding : utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    (c) 2010 by Hannes Georg
#
module Splash
  
  module MapReduce
    
    # hack!
    # If we would set a constant to the class, it would be named to that constant.
    # Yet, we don't want that.
    BASE = [Class.new{
      
      include Splash::Documentbase
      include Splash::HasAttributes
      include Splash::HasCollection
      
    }].freeze
    
    extend Cautious
    
    module ClassMethods
      
      def from_callback(callback,map,reduce,options,&block)
        thiz = self
        
        map = BSON::Code.new(map) if map.kind_of? String
        reduce = BSON::Code.new(reduce) if reduce.kind_of? String
        
        map.freeze
        reduce.freeze
        
        options.freeze
        callback.freeze
        
        c = Class.new(BASE.first) do
          
          ex = class << self
            self.method(:define_method)
          end
          
          if map
            ex.call(:map) do
              return map
            end
          else
            ex.call(:map) do
              raise NoMethod, "No map function given and 'map' not implemented."
            end
          end
          
          if reduce
            ex.call(:reduce) do
              return reduce
            end
          else
            ex.call(:reduce) do
              raise NoMethod, "No reduce function given and 'reduce' not implemented."
            end
          end
          
          ex.call(:map_reduce_callback) do
            return callback
          end
          ex.call(:map_reduce_base_options) do
            return options
          end
          
          class << self
            private :map_reduce_callback
          end
          
          extend thiz
          
        end
        if block_given?
          c.class_eval &block
        end
        return c
      end
      
    end
    
    def self.[](scope, map=nil, reduce=nil, options={},&block)
      return scope.map_reduce(map, reduce, options.merge(:keeptemp => true),&block)
    end
    
    module Temporary
      
      include Splash::MapReduce
      #extend Splash::MapReduce::ClassMethods
      
      def collection
        refresh!
        super
      end
      
      def map_reduce_options
        options = map_reduce_base_options.dup
        options[:keeptemp] = false
        options[:raw] = true
        options[:out] = nil
        return options
      end
      
    end
    
    module Permanent
      
      include Splash::MapReduce
      #extend Splash::MapReduce::ClassMethods
      
      def map_reduce_options
        options = map_reduce_base_options.dup
        options[:keeptemp] = true
        options[:raw] = true
        options[:out] = self.collection.name
        return options
      end
      
    end
    
    def refresh!
      result = map_reduce_callback.call(map,reduce,self.map_reduce_options)
      self.collection = self.namespace.collection(result["result"])
      return result.except("result","ok")
    end
    
    
  end
  
end