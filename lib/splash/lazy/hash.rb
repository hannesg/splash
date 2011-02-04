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
require "sync.rb"
module Splash
module Lazy
  
  class Hash < ::Hash
    
    alias_method :present_keys, :keys
    alias_method :key_present?, :key?
    
    def inspect
      i = []
      self.present_keys.each do |k|
        i << "#{k.inspect} => #{self[k].inspect}"
      end
      i << " lazy:#{@lazy_keys.inspect}, all_other: #{@lazy_keys.default} "
      return '{' + i.join(', ') + '}'
    end
    
    def deep_clone
      result = Lazy::Hash.new(@fetcher,lazy_mode)
      self.present_keys.each do |k|
        result[k.deep_clone] = self[k].deep_clone
      end
      @lazy_keys.each do |k,v|
        if v
          result.lazify!(k)
        else
          result.unlazify!(k)
        end
      end
      return result
    end
    
    def each
      self.complete!
      return super
    end
    
    def key?(key)
      self.demand!(key)
      return super
    end
    
    def keys
      self.complete!
      super
    end
    
    def map
      self.complete!
      super
    end
    
    def [](key)
      self.demand!(key)
      return super
    end
    
    def []=(key,value)
      self.unlazify!(key)
      return super
    end
    
    def delete(key)
      self.unlazify!(key)
      return super
    end
    
    def values_at(*keys)
      self.demand!(*keys)
      return super
    end
    
    def slice(*keys)
      self.demand!(*keys)
      return super
    end
    
    def complete?
      @lazy_complete
    end
    
    def initialize(fetcher, mode=:exclusive)
      @fetcher = fetcher
      @lazy_complete = false
      @lazy_keys = ::Hash.new
      @lazy_sync = Sync.new
      @lazy_mapper = nil
      self.lazy_mode = mode
      return self
    end
    
    attr_accessor :lazy_mapper
    
    def lazy_mode
      return @lazy_keys.default ? :inclusive : :exclusive
    end
    
    def lazy_mode=(mode)
      @lazy_sync.synchronize(Sync::SH) do
        @lazy_keys.default = mode==:inclusive
      end
    end
    
    def demand!(*keys)
      return if complete?
      @lazy_sync.synchronize(Sync::EX) do
        keys = keys.select{|k| self.lazy? k }
        return if keys.none?
        result = @fetcher.slice(*keys)
        if result.available?
          keys.each do |k|
            if result.key? k
              self[k] = result[k]
            else
              self.delete(k)
            end
          end
        else
          self.complete = true
        end
        #self.unlazify!(*keys)
      end
    end
    
    def lazy?(key)
      return false if complete?
      @lazy_sync.synchronize(Sync::SH) do
        return false if complete?
        #return false if self.key_present? key
        return @lazy_keys[key]
      end
    end
    
    def complete!
      return if complete?
      @lazy_sync.synchronize(Sync::EX) do
        return if complete?
        result = @fetcher.to_h
        if result.available?
          result.each do |k,v|
            if lazy? k
              self[k] = v
            end
          end
        end
        self.complete = true
      end
    end
    
    def lazify!(*keys)
      return if complete?
      @lazy_sync.synchronize(Sync::SH) do
        return if complete?
        keys.flatten.each do |key|
          @lazy_keys[key] = true
        end
      end
    end
    
    def unlazify!(*keys)
      return if complete?
      @lazy_sync.synchronize(Sync::SH) do
        return if complete?
        keys.flatten.each do |key|
          @lazy_keys[key] = false
        end
      end
    end
    
    def hmmm!(result)
      @lazy_sync.synchronize(Sync::EX) do
        result.each do |k,v|
          self[k] = v
        end
      end
    end
    
    def integrate!(keys,result)
      @lazy_sync.synchronize(Sync::EX) do
        keys.each do |k|
          if result.key? k
            self[k] = result[k]
          else
            self.delete(k)
          end
        end
      end
    end
    
protected
    def complete=(c)
      @lazy_complete = c
      if c
        @lazy_keys.clear
      end
    end
  end
  
end
end