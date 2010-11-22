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
  module Lazy::Collection
    
    def self.included(base)
      base.class_eval do
        alias_method_chain :find, :lazy
      end
    end
    
    def find_with_lazy(selector={}, opts={})
      has_fields = opts.key?(:fields)
      #puts "find?"
      cursor = find_without_lazy(selector,opts)
      if has_fields and cursor.kind_of? Mongo::Cursor
        cursor.extend(Lazy::Cursor)
      end
      if block_given?
        yield cursor
        cursor.close
        return nil
      end
      return cursor
    end
    
    def self.invade!
      unless Mongo::Collection < Lazy::Collection
        puts "invaded!"
        Mongo::Collection.send(:include,Lazy::Collection)
      end
      #puts ::Mongo::Collection.included_modules.inspect
      #c = Mongo::Collection.instance_method(:find)
      #puts c.owner.inspect
    end
    
  end
  
  module Lazy
    
    def Collection(col)
      return col.kind_of?(Lazy::Collection) ? col : col.extend(Lazy::Collection)
    end
    
  end
end