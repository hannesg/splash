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
  module Hash::Base #< ::Hash
    def complete?
      @lazy_complete
    end
    
    def initialize_laziness(fetcher)
      @fetcher = fetcher
      return self
    end
    
    def demand!(*keys)
      return if complete?
      @lazy_mutex.synchronize do
        keys = keys.select{|k| self.lazy? k }
        return if keys.none?
        result = @fetcher[keys]
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
        unlazify(*keys)
      end
    end
    
    def complete!
      return if complete?
      @lazy_mutex.synchronize do
        return if complete?
        result = @fetcher.all
        if result.available?
          self.reverse_merge!(result)
        end
        @lazy_complete = true
      end
    end
    
  end
end
end