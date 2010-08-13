module Splash
  module HasAttributes
    
    class Attributes < Hash
      def load(raw)
        raw.each do |key,value|
          key=key.to_s
          
          
          if value.kind_of? type(key).persisted_class
            self[key]=value
          elsif Splash::Persister.raw? value
            @raw[key]=value
          else
            
            puts value.class
            puts type(key).persisted_class
            raise "Don't know what to do with #{key}= #{value.inspect}"
          end
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
        return self[key]=value
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
      
      def def_attribute(name,*args,&block)
        name = name.to_s
        attr=attributes[name]=Splash::Attribute.new(*args, &block)
        attribute_accessor(name)
        return attr
      end
      
      def attribute(name,create = true)
        name = name.to_s
        each_attributes do |attr|
          return attr[name] if attr.key? name
        end
        if create
          return def_attribute(name)
        end
        return nil
      end
      
    end
  end
end