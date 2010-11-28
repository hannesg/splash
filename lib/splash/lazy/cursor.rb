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
  module Lazy::Cursor
      
    def self.extended(base)
      base.instance_eval do
        result = {}
        keys = @fields.keys.sort_by &:length
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
        @lazy_fields = result
      end
    end
    
    def next_document
      d = super
      return nil if d.nil?
      make_lazy(d)
    end
private
    def make_lazy(document)
      return document if @lazy_fields.none?
      id = document['_id']
      if @fields.value?(1)
        @lazy_fields.each do |key,value|
          DotNotation::Enumerator.new(document,key).each do |path,hsh|
            if hsh.kind_of? ::Hash
              hsh.extend(Lazy::Hash::Inclusive)
              hsh.initialize_laziness(collection,id,path.join('.'))
              hsh.unlazify(*value)
            end
          end
        end
      else
        @lazy_fields.each do |key,value|
          DotNotation::Enumerator.new(document,key).each do |path,hsh|
            if hsh.kind_of? ::Hash
              hsh.extend(Lazy::Hash::Exclusive)
              hsh.initialize_laziness(@collection,id,path.join('.'))
              hsh.lazify(*value)
            end
          end
        end
      end
      return document
    end
    
  end
end