require "delegate"
module Splash
  module Lazy
    class Persister < Delegator
      def initialize(name,*args,&block)
        @persister=HasAttributes.get_persister(name,*args, &block)
        super(@persister)
      end

      def __getobj__
        @persister
      end

      def __setobj__(obj)
        @persister=obj
      end

      def persist_class(klass)
      end
    
      def bind_to(klass)
        klass.class_eval "nopreload! #{name.inspect}"
      end

      def missing(object)
        if( object.class < Saveable and object.stored? )
          puts "lazy loaded! #{name}"
          query=object.find_self.fieldmode(:include).preload(name)
          puts query.inspect
          doc = query.next_raw_document
          if doc.nil?
            return @persister.missing(object)
          end
          return doc[name]
        end
        @persister.missing(object)
      end
      
    end
    
    self.persister= Splash::Lazy::Persister
    
  end
end