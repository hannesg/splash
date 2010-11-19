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
  
  module ActsAsScope::MapReduceInterface
    
    MAP_REDUCE_QUERY_KEYS = [:query,:sort,:limit].to_set
    
    
    def map_reduce(map=nil,reduce=nil,opts={},&block)
      if MAP_REDUCE_QUERY_KEYS.any?{|k| opts.key? k }
        return self.query(opts.slice(*MAP_REDUCE_QUERY_KEYS)).map_reduce(map,reduce,opts.except(*MAP_REDUCE_QUERY_KEYS))
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