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
require 'facets/object/dup'
module Splash
  module HasAttributes
    class Attributes < Hash
      
      KEY_REGEX = /^_attribute_([a-z_]*)_type$/.freeze
      
      include HasAttributes::GeneratesUpdates
      
      alias_method :read, :[]
      alias_method :write, :[]=
      
      def dup
        d = super
        d.instance_eval do
          @deleted_keys = @deleted_keys.dup
          @sync = @sync.dup
          keys.each do |k|
            v = self[k]
            if v.dup? and !v.frozen?
              self[k] = v.dup
            end
          end
        end
        return d
      end
      
      def load(attrs)
        attrs.each do |key,value|
          self[key]=value
        end
      end
      
      def dirty?(key)
        return true if @deleted_keys.include? key
        return self.key? key
      end
      
      def clean?(key)
        !dirty?(key)
      end
      
      # this is a brain transplantation!
      def load_raw(raw)
        @sync.synchronize(Sync::EX){
          flush!
          @raw = raw
        }
      end
      
      def [](key)
        @sync.synchronize(Sync::SH){
        return ::NA if( @deleted_keys.include? key )
        return self.read(key) if( self.key_present? key )
          @sync.synchronize(Sync::EX){
            return self.read(key) if( self.key_present? key )
            if( @raw.key? key )
              value = @class.attribute_persister(key).from_saveable(@raw[key])
            else
              value = @class.attribute_default(key)
            end
            if ::NA == value
              self.delete(key)
            else
              self.write(key,value)
              @deleted_keys.delete key
            end
            return value
          }
        }
      end
      
      alias key_without_magic? key?
      
      def key?(k)
        return false if @deleted_keys.include? k
        return true if super
        return default_defined?(k)
      end
      
      def key_present?(k)
        return false if @deleted_keys.include? k
        return key_without_magic?(k)
      end
      
      alias keys_without_magic keys
      
      def keys
        k = super
        @class.methods do |meth|
          if meth =~ KEY_REGEX
            meth << $1
          end
        end
        return k.uniq
      end
      
      def []=(key,value)
        @sync.synchronize(Sync::EX){
          if ::NA == value
            self.delete(key)
          else
            self.write(key,@class.attribute_setter(key,value))
            @deleted_keys.delete key
          end
        }
      end
      
      def delete(key)
        value = super
        @deleted_keys << key
        return value
      end
      
      def initialize(klass)
        super()
        @class = klass
        @raw = {}
        @sync = Sync::Dummy.new
        @deleted_keys = Set.new
        @complete_before_write = true
        @completed = false
        #complete!
      end
      
      def raw
        return write_into!(@raw.deep_clone)
      end
      
      def type(key)
        return @class.attribute(key)
      end
      
      def each
        @sync.synchronize(Sync::SH){
          super
        }
      end
      
      def write_back!
        @sync.synchronize(Sync::EX){
          write_into!(@raw)
          @deleted_keys.clear
        }
        return self
      end
      
      def reset!
        @sync.synchronize(Sync::EX){
          flush!
        }
        return self
      end
      
      def ignore_defaults!
        @complete_before_write = false
      end
      
      def default_defined?(key)
        return @class.respond_to?("_attribute_#{key}_default".to_sym)
      end
      
      def defined?(key)
        return @class.respond_to?("_attribute_#{key}_type".to_sym)
      end
      
=begin
      def each
        keys.each do |key|
          yield(key,self[key])
        end
      end
=end
      def inspect
        complete!
        super
      end 
      
      def update(values)
        raise ArgumentError, "Expected to receive a Hash, but got #{values.inspect}." unless values.kind_of? Hash
        values.each do |k,v|
          self[k] = v
        end
        return self
      end

      protected
        def complete!
          return self if @completed
          keys = Set.new
          matcher = /^_attribute_([a-z_]+)_default$/
          @class.methods.each do |meth|
            if matcher =~ meth.to_s
              unless @deleted_keys.include?($1) or self.key_present?($1)
                self[$1]
              end
            end
          end
          @completed = true
          return self
        end
        
        def flush!
          self.replace({})
          @deleted_keys = Set.new
          @completed = false
          @complete_before_write = true
        end
        
        def write_into!(target={})
          complete! if @complete_before_write
          self.each do |key,value|
            target[key]=@class.attribute_persister(key).to_saveable(value)
          end
          @deleted_keys.each do |key|
            target.delete(key)
          end
          return target
        end
    end
  end
end
