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
      
      alias_method :read, :[]
      alias_method :write, :[]=
      
      def load(attrs)
        attrs.each do |key,value|
          self[key]=value
        end
      end
      
      # this is a brain transplantation!
      def load_raw(raw)
        flush!
        @raw = raw
      end
      
      def [](key)
        return nil if( @not_given.include? key )
        return super if( self.key? key )
        #t=type(key)
        if( @raw.key? key )
          value = @class.attribute_persister(key).from_saveable(demand(@raw[key]))
        else
          value = @class.attribute_default(key)
        end
        self.write(key,value)
        return value
      end
      
      def []=(key,value)
        if ::NA == value
          @not_given << key
          self.delete(key)
          @raw.delete(key)
        elsif value.kind_of? @class.attribute_type(key)
          @not_given.delete(key)
          self.write(key,value)
        elsif Splash::Persister.raw? value
          @not_given.delete(key)
          @raw[key]=value
          self.delete(key)
        else
          raise "Don't know what to do with #{key}= #{value.inspect}"
        end
      end
      
      def initialize(klass)
        super()
        @class = klass
        @raw = {}
        @not_given = Set.new
        #complete!
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
              unless @not_given.include?(a[1]) or self.key?(a[1])
                self[a[1]]=@class.send(meth)
              end
            end
          end
          return self
        end
        
        def flush!
          self.replace({})
          @not_given = Set.new
        end
        
        def write_back!
          #complete!
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
        return ::NA unless self.respond_to?(a)
        return attribute_type(name).instance_eval &send(a)
      end
      
      def from_raw(data,*args,&block)
        o = self.allocate
        o.attributes.load_raw(data)
        o.initialize(*args,&block)
        return o
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
