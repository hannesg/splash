# -*- encoding : utf-8 -*-
module Splash
  module HasAttributes
    
    class Attributes < Hash
      
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
        return super if( self.key? key )
        t=type(key)
        if( @raw.key? key )
          value = t.read(@raw[key])
        else
          value = t.default
        end
        self.write(key,value)
        return value
      end
      
      def []=(key,value)
        return if ::NotGiven == value
        key=key.to_s
        if value.kind_of? type(key).type
          self.write(key,value)
        elsif Splash::Persister.raw? value
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
          @class.each_attributes do |attrs|
            attrs.each do |k,v|
              unless keys.include?(k)
                keys << k
                self[k]=v.initial_value
              end
              
            end
          end
          return self
        end
        
        def write_back!
          self.each do |key,value|
            @raw[key]=type(key).write(value)
          end
        end
    end
    
    class << self
      def included(base)
        base.extend(ClassMethods)
        base.instance_eval do
          merged_inheritable_attr :attributes,{}
        end
      end
    end
    
    def attributes
      @attributes ||= Attributes.new(self.class)
    end
    
    def attribute(name)
      self.class.attribute(name)
    end
    
    def respond_to?(meth)
      return true if meth =~/^([a-zA-Z_]+)\?$/
      return true if meth =~ /^([a-zA-Z_]+)=$/
      super(meth)
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
      
      def attribute(name,*args,&block)
        name = name.to_s
        each_attributes do |attrs|
          if attrs.key? name
            if args.size > 0 || block
              warn "trying to add the existing attribute #{name} of #{self}"
              break
            end
            return attrs[name]
          end
        end
        attr=attributes[name]=Splash::Attribute.new(*args, &block)
        attribute_accessor(name)
        return attr
      end
      
      alias def_attribute attribute
      
      def attribute?(name)
        name = name.to_s
        each_attributes do |attr|
          return true if attr.key? name
        end
        return false
      end
      
      def from_raw(data)
        c = self.new()
        c
        c.attributes.load_raw(data)
        return c
      end
      
    end
  end
end
