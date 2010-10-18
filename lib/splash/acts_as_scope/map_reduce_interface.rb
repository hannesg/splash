# -*- encoding : utf-8 -*-
module Splash
  
  module ActsAsScope::MapReduceInterface
    
    MAP_REDUCE_QUERY_KEYS = [:query,:sort,:limit].to_set
    
    
    def map_reduce(map=nil,reduce=nil,opts={},&block)
      if MAP_REDUCE_QUERY_KEYS.any?{|k| opts.key? k }
        return self.query(opts.only(MAP_REDUCE_QUERY_KEYS)).map_reduce(map,reduce,opts.except(MAP_REDUCE_QUERY_KEYS))
      end
        
      if( opts[:out] || opts[:keeptemp] )
        return Splash::MapReduce::Permanent.from_callback(self.method(:_map_reduce), map, reduce, opts, &block)
      else
        return Splash::MapReduce::Temporary.from_callback(self.method(:_map_reduce), map, reduce, opts, &block)
      end
    end
    
    protected
    
    def _map_reduce(map,reduce,opts)
      opts = opts.dup
      query, options = self.find_options
      opts[:query] = query
      
      return self.scope_root.collection.map_reduce(map,reduce,opts)
    end
    
  end
  
  
end