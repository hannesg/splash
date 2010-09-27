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
        key=key.to_s
        if value.kind_of? type(key).persisted_class
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
      end
      
      def raw
        write_back!
        return @raw
      end
      
      def type(key)
        return @class.attribute(key)
      end
      
      protected
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
      
      def get_persister(*args,&block)
        klass = Object
        if args.length > 0
          if args.first.respond_to? :persister
            klass = args.shift
          end
        end
        type = (klass).persister
        result=type.new(*args,&block)
        result.persist_class(klass)
        return result
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
      "#{self.class.to_s}{#{attributes.inspect}}"
    end
    
    def to_saveable
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
      
    end
  end
end