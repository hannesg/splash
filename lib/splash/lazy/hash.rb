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
    
    HIS_ROYAL_LAZINESS = ArgumentError.new
    
    class Hash < Hash
    
      # In the exclusive model, you decide explicitly, which keys are
      # lazy. All others aren't!
      module Exclusive
        
        def self.extended(base)
          base.instance_eval do
            @lazy_model = nil
            @lazy_id = nil
            @lazy_path = nil
            @lazy_fields = nil
            @lazy_mutex = Mutex.new
          end
        end
        
        def [](key,load=true)
          v = super(key)
          if load and v == HIS_ROYAL_LAZINESS 
            self.demand!(key)
            return super(key)
          end
          return v
        end
        
        def key?(key,load=true)
          if !load
            return super(key)
          elsif super(key)
            if self.lazy?(key)
              demand!(key)
            end
            return super(key)
          else
            return false
          end
        end
        
        def lazy?(field)
          self[field,false] == HIS_ROYAL_LAZINESS 
        end
        
        def initialize_laziness(model,id,path)
          @lazy_model, @lazy_id, @lazy_path = model, id, path
          return self
        end
        
        def lazify(*fields)
          @lazy_mutex.synchronize do
            fields.each do |field|
              unless self.key?(field,false)
                self[field]=HIS_ROYAL_LAZINESS
              end
            end
          end
        end
        
        def demand!(*keys)
          @lazy_mutex.synchronize do
            keys = keys.select{|k| self.lazy? k }
            return if keys.none?
            fields = keys.inject({}){|memo,k| memo[DotNotation.join(@lazy_path,k)]=1; memo }
=begin
  # maybe nesting will be possible somewhen
            lazy_child_fields = {}
            keys.each do |k|
              ck = k+'.'
              lazy_child_fields << @lazy_fields.select{|k2,v2|
                v2 == 1 and k2.starts_with(ck)
              }
            end
=end
            docs = @lazy_model.collection.find({"_id"=>@lazy_id},{:fields=>(fields)})
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
            keys.each do |k|
              self.delete(k)
            end
          end
        end
      end
      def self.insert(model,id,document,fields)
        result = {}
        keys = fields.keys.sort_by &:length
        rkeys = Set.new
        keys.each do |key|
          if fields[key] == 0
            if rkeys.any?{|key2| key2.starts_with? key}
              raise "Nesting lazy/eager fields is currently not support by MongoDB, so we didn't implented it."
            else
              path, sub = DotNotation.pop(key)
              result[path] ||= Set.new
              result[path] << sub
              rkeys << key
            end
          end
        end
        result.each do |key,value|
          DotNotation::Enumerator.new(document,key).each do |path,hsh|
            if hsh.kind_of? ::Hash
              hsh.extend(Exclusive)
              hsh.initialize_laziness(model,id,path.join('.'))
              hsh.lazify(*(value.to_a))
            end
          end
        end
        return document
      end
    end
    
  end
end