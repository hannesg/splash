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
    
    class Ness
      def new
        @@instance ||= super
      end
      def self._load(str)
        self.new
      end
      def _store(limit)
        'lazy'
      end
      def inspect
        '<his royal laziness>'
      end
    end
        
    HIS_ROYAL_LAZINESS = Ness.new
    
    module Hash
      
      autoload_all File.join(File.dirname(__FILE__),'hash')
      
      def self.insert(collection,id,document,fields)
        if fields.none?
          return document
        end
        result = {}
        keys = fields.keys.sort_by &:length
        rkeys = Set.new
        keys.each do |key|
          if rkeys.any?{|key2| key2.starts_with? key}
            raise "Nesting lazy/eager fields is currently not support by MongoDB, so we didn't implented it."
          else
            path, sub = DotNotation.pop(key)
            result[path] ||= Set.new
            result[path] << sub
            rkeys << key
          end
        end
        if fields.value?(1)
          result.each do |key,value|
            DotNotation::Enumerator.new(document,key).each do |path,hsh|
              if hsh.kind_of? ::Hash
                hsh.extend(Inclusive)
                hsh.initialize_laziness(collection,id,path.join('.'))
              end
            end
          end
        else
          result.each do |key,value|
            DotNotation::Enumerator.new(document,key).each do |path,hsh|
              if hsh.kind_of? ::Hash
                hsh.extend(Exclusive)
                hsh.initialize_laziness(collection,id,path.join('.'))
                hsh.lazify(*(value.to_a))
              end
            end
          end
        end
        return document
      end
    end
    
  end
end