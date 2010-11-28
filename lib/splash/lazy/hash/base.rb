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
require "set"
module Splash
module Lazy
  module Hash::Base
    def complete?
      @lazy_complete
    end
    
    def demand!(*keys)
      return if complete?
      @lazy_mutex.synchronize do
        keys = keys.select{|k| self.lazy? k }
        return if keys.none?
        fields = keys.inject({}){|memo,k| memo[DotNotation.join(@lazy_path,k)]=1; memo }
        docs = @lazy_collection.find_without_lazy({'_id'=>@lazy_id},{:fields=>(fields)})
        if docs.has_next?
          doc = docs.next_document
          result = DotNotation.get(doc,@lazy_path)
          if result.available?
            keys.each do |k|
              if result.key? k
                self[k] = result[k]
              else
                self.delete(k)
              end
            end
            return ;
          end
        end
        unlazify(*keys)
      end
    end
    
    def complete!
      return if complete?
      @lazy_mutex.synchronize do
        docs = @lazy_collection.find_without_lazy({'_id'=>@lazy_id},{:fields=>{@lazy_path => 1}})
        if docs.has_next?
          doc = docs.next_document
          result = DotNotation.get(doc,@lazy_path)
          if result.available?
            self.reverse_merge!(result)
          end
        end
        @lazy_complete = true
      end
    end
    
  end
end
end