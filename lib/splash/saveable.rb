# -*- encoding : utf-8 -*-
module Splash
  module Saveable
    class Persister < Splash::Persister
      def write(value)
        return nil if value.nil?
        return value._id
      end
      
      def read(value)
        return nil if value.nil?
        return persisted_class.with_id(value).first
      end
    end
    
    class MultiPersister < Splash::Persister
      def write(value)
        return nil if value.nil?
        return BSON::DBRef.new(value.class.collection.name,value._id)
      end
      
      def read(value)
        return nil if value.nil?
        return @persisted_class.namespace.dereference(value)
      end
    end
    
    class EmbedPersister < Splash::Persister
      def write(value)
        return nil if value.nil?
        return Saveable.wrap(value)
      end
      
      def read(value)
        return nil if value.nil?
        return Saveable.load(value,persisted_class)
      end
    end
    
    self.persister= MultiPersister
    
    UPPERCASE=65..90
    
    class << self
      def included(base)
        base.extend(ClassMethods)
        base.persister=Splash::Saveable::Persister
      end
      
      def unwrap(keys)
        keys.inject({}) do |hsh,(key,val)| hsh[key]=val unless UPPERCASE.include? key[0]; hsh end
      end
      
      def wrap(object)
        to_saveable(object).merge("Type"=>Saveable.get_class_hierachie(object.class).map(&:to_s))
      end
      
      def load(keys,klass=Hash)
        if keys.nil?
          keys={}
        end
        if keys["Type"]
          klass = Kernel.eval(keys["Type"].first)
        end
        return klass.from_saveable(self.unwrap(keys))
      end
      
      def to_saveable(obj)
        if obj.respond_to? :to_saveable
          return obj.to_saveable
        end
        return obj
      end
      
      def get_class_hierachie(klass)
        base=[]
        begin
          if klass.named?
            base << klass
          end
          #return base unless klass.instance_of? Class
          klass = klass.superclass
        end while ( klass < Splash::HasAttributes )
        return base
      end
    end
    
    def namespace
      self.class.namespace
    end
    
    def storable_id
      self.attributes["_id"]
    end
    
    def storable_id=(val)
      self.attributes["_id"]=val
    end
    
    protected :storable_id=
    
    def store!
      self.storable_id=self.class.store!(self)
      return self
    end
    
    def remove!
      return self.class.collection.remove('_id'=>self.storable_id)
    end
    
    def stored?
      return !storable_id.nil?
    end
    
    def find_self
      self.class.with_id(self.storable_id)
    end
    
    def ==(other)
      return ( other.kind_of?(Saveable) and self.namespace == other.namespace and self.storable_id == other.storable_id )
    end
    
    module ClassMethods
      
      def <<(obj)
        obj.store!
      end
      
      def store!(object)
        return self.collection.save(
          Saveable.wrap(object)
        );
      end
      
      def namespace
        @namespace ||= Splash::Namespace.default
      end
      
      def collection
        @collection ||= namespace.collection_for(self)
      end
      
=begin
      def [](*args)
        a=args.flatten
        if a.length == 1 
          return with_id(a).first
        else
          return with_id(a).finish!
        end
      end
=end
      def from_saveable(data)
        self.new(data)
      end
    end
  end
end
