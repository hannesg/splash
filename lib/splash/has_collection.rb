module Splash
  
  module HasCollection
    
    def self.included(base)
      super(base)
      base.extend(ClassMethods)
    end
    
    def store!
      self._id=self.class.store!(self)
      return self
    end
    
    def remove!
      return self.class.collection.remove('_id'=>self._id)
    end
    
    def initialize(*args)
      self._id = self.class.collection.pk_factory.new
      super
    end
    
    def find_self
      self.class.with_id(self._id)
    end
    
    def ==(other)
      return ( other.kind_of?(Splash::HasCollection) and self.class.namespace == other.class.namespace and self._id == other._id )
    end
    
    alias eq? ==
    
    module ClassMethods
      
      def <<(obj)
        obj.store!
      end
      
      def store!(object)
        return self.collection.save(
          Saveable.wrap(object)
        );
      end
      
      def namespace(*args)
        if args.any?
          self.namespace=args.first
        end
        return (@namespace || Splash::Namespace.default)
      end
      
      def namespace=(arg)
        if arg.kind_of? Splash::Namespace
          @namespace = arg
          @collection = nil
        else
          @namespace = Splash::Namespace::NAMSPACE[arg]
          @collection = nil
        end
      end
      
      def collection(*args)
        if args.any?
          self.collection= args.first
        end
        return (@collection ||= namespace.collection_for(self))
      end
      
      def collection=(arg)
        @collection = arg
      end
      
    end
    
  end
  
end