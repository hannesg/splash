# -*- encoding : utf-8 -*-
module Splash
  module Saveable
    
    UPPERCASE=65..90
    
    class << self
      
      def unwrap(keys)
        keys.inject({}) do |hsh,(key,val)| hsh[key]=val unless UPPERCASE.include? key[0]; hsh end
      end
      
      def wrap(object)
        object.to_raw.merge("Type"=>Saveable.get_class_hierachie(object.class).map(&:to_s))
      end
      
      def load(keys,klass=Hash)
        if keys.nil?
          keys={}
        end
        #puts klass
        if keys["Type"]
          klass = Kernel.eval(keys["Type"].first)
        end
        return klass.from_raw(self.unwrap(keys))
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
    
  end
end
