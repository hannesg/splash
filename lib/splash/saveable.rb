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
  module Saveable
    
    UPPERCASE=65..90
    
    class << self
      
      def unwrap(keys)
        keys.inject({}) do |hsh,(key,val)| hsh[key]=val unless UPPERCASE.include? key[0]; hsh end
      end
      
      def wrap(object)
        object.to_raw.reject{|k,v| ::NotGiven == v }.merge("Type"=>Saveable.get_class_hierachie(object.class).map(&:to_s))
      end
      
      def load(keys,klass=Hash)
        if keys.nil?
          keys={}
        end
        #puts klass
        if keys["Type"]
          klass = Kernel.eval(keys["Type"].first)
        end
        return klass.from_raw(self.unwrap(keys))
      end
      
      def get_class_hierachie(klass)
        base=[]
        begin
          if klass.named?
            base << klass
          end
          #return base unless klass.instance_of? Class
          klass = klass.superclass
        end while ( klass < Splash::HasAttributes )
        return base
      end
    end
    
  end
end
