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
  module HasAttributes
    class Attributes < BSON::OrderedHash
      
      include HasAttributes::GeneratesUpdates
      
      alias_method :read, :[]
      alias_method :write, :[]=
      
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
        return self.read(key) if( self.key? key )
          @sync.synchronize(Sync::EX){
            return super if( self.key? key )
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
      
      def key?(k)
        return false if @deleted_keys.include? k
        return super
      end
      
      def []=(key,value)
        @sync.synchronize(Sync::EX){
          if ::NA == value
            self.delete(key)
          else
            self.write(key,value)
            @deleted_keys.delete key
          end
        }
      end
      
      def delete(key)
        super
        @deleted_keys << key
      end
      
      def initialize(klass)
        super()
        @class = klass
        @raw = {}
        @sync = Sync::Dummy.new
        @deleted_keys = Set.new
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
      
      protected
        def complete!
          keys = Set.new
          matcher = /^attribute_([a-z_]+)_default$/
          @class.methods do |meth|
            if match = matcher.match(meth.to_s)
              a = match.to_a
              unless @not_given.include?(a[1]) or self.key?(a[1])
                self[a[1]]=@class.send(meth)
              end
            end
          end
          return self
        end
        
        def flush!
          self.replace({})
          @deleted_keys = Set.new
        end
        
        def write_into!(target={})
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
