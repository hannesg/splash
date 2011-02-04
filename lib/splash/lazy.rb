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
  
  module Lazy
    autoload_all File.join(File.dirname(__FILE__),'lazy')
    
    def self.build_lazy_options(fields)
      result = {}
      keys = fields.keys.sort_by &:length
      root = {}
      keys.each do |key|
        found = false
        result.each do |k,v|
          if key.starts_with? k
            v[key[(k.length+1)..-1]] = fields[key]
            found = true
            break
          end
        end
        unless found
          root[key]=result[key]={}
        end
      end
      return root
    end
    
    def self.insert(model,id,document,fields)
      options = self.build_lazy_options(fields)
      options.each do |key,value|
        DotNotation::Enumerator.new(document,key).map! do |path,old|
          Lazy::FetchPromise.new(model,id,path.join('.'),value)
        end
      end
      return document
    end
    
    def self.demand!(value)
      if value.kind_of?(::Hash)
        result = {}
        value.each do |k,v|
          result[k] = demand!(v)
        end
        return result
      elsif value.kind_of?(::Array)
        result = []
        value.each do |v|
          result << demand!(v)
        end
        return result
      else
        return value
      end
    end
    
  end
end