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
    
    class Attributes < Hash
      
      alias_method :orig_key?, :key?
      alias_method :read, :[]
      alias_method :write, :[]=
      
      def load(raw)
        raw.each do |key,value|
          self[key]=value
        end
      end
      
      def load_raw(raw)
        raw.keys.each do |k|
          self.delete k
        end
        @raw.update(raw)
      end
      
      def [](key)
        return super if( self.orig_key? key )
        #t=type(key)
        if( @raw.key? key )
          value = @class.attribute_persister(key).from_saveable(@raw[key])
        else
          value = @class.attribute_default(key)
        end
        self.write(key,value)
        return value
      end
      
      def []=(key,value)
        key=key.to_s
        if ::NotGiven == value
          self.write(key,value)
          @raw[key]=value
        elsif value.kind_of? @class.attribute_type(key)
          self.write(key,value)
        elsif Splash::Persister.raw? value
          @raw[key]=value
          self.delete(key)
        else
          raise "Don't know what to do with #{key}= #{value.inspect}"
        end
      end
      
      def key?(key)
        super and ::NotGiven != self.read(key)
      end
      
      def initialize(klass)
        super()
        @class = klass
        @raw = {}
        #@completed = false
        complete!
      end
      
      def raw
        write_back!
        return @raw
      end
      
      def type(key)
        return @class.attribute(key)
      end
      
      protected
        def complete!
          keys = Set.new
          matcher = /^attribute_([a-z_]+)_default$/
          @class.methods do |meth|
            if match = matcher.match(meth.to_s)
              a = match.to_a
              self[a[1]]=@class.send(meth)
            end
          end
          return self
        end
        
        def write_back!
          self.each do |key,value|
            @raw[key]=@class.attribute_persister(key).to_saveable(value)
          end
        end
    end
    
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end
    
    def attributes
      @attributes ||= Attributes.new(self.class)
    end
    
    def attribute(name)
      self.class.attribute(name)
    end
    
    def respond_to?(meth, include_private=false)
      return true if meth =~/^([a-zA-Z_]+)\?$/
      return true if meth =~ /^([a-zA-Z_]+)=$/
      super(meth, include_private)
    end
    
    def inspect
      "#{self.class.to_s}{#{attributes.raw.inspect}}"
    end
    
    def to_raw
      attributes.raw
    end
    
    def method_missing(meth,*args,&block)
      if( meth.to_s =~ /^([a-zA-Z_]+)=$/ && args.size == 1 )
        # setter
        return attributes[$1]=args.first
      elsif( meth.to_s =~ /^([a-zA-Z_]+)$/ && args.size == 0 )
        return attributes[$1]
      elsif( meth.to_s =~ /^([a-zA-Z_]+)\?$/ && args.size == 0 )
        return attributes.key?(meth.to_s) 
      end
      super
    end
    
    def initialize(attr={})
      self.attributes.load(attr)
      super()
    end
    
    module ClassMethods
      
      def attribute_accessor(name)
        self.class_eval <<-CODE, __FILE__, __LINE__
def #{name.to_s}() return attributes[#{name.to_s.inspect}] end
def #{name.to_s}=(value) return attributes[#{name.to_s.inspect}] = value end
CODE
      end
      
      def attribute_class
        @attribute_class ||= Class.new(Splash::Attribute)
      end
      
      def attribute(name,*args,&block)
        name = name.to_s
        attr = attribute_class.new(self,name)
        if args.any? or block_given?
          attr.make(*args, &block)
        end
        attribute_accessor(name)
        return attr
      end
      
      def attribute_persister(name)
        a = "attribute_#{name}_persister"
        return Object unless self.respond_to? a
        return send(a)
      end
      
      def attribute_type(name)
        a = "attribute_#{name}_type"
        return Object unless self.respond_to? a
        return send(a)
      end
      
      def attribute_default(name)
        a = "attribute_#{name}_default"
        return ::NotGiven unless self.respond_to?(a)
        return attribute_type(name).instance_eval &send(a)
      end
      
      def from_raw(data)
        c = self.new_without_defaults()
        c.attributes.load_raw(data)
        return c
      end
      
      def new_with_defaults(*args,&block)
        o = self.allocate
        o.attributes.complete!
        o.initialize(*args,&block)
        return o
      end
      
      def new_without_defaults(*args,&block)
        o = self.allocate
        o.initialize(*args,&block)
        return o
      end
      
    end
  end
end
