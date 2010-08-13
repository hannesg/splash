module Splash::Annotated
  
  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end
  
  
  module ClassMethods
  
    def method_added(meth)
      apply_annotations(meth)
      super
    end
    
    def apply_annotations(meth)
      return if @annotations.nil?
      @annotations.each do |(fn,args,block)|
        args.unshift(meth)
        self.send(fn,*args,&block)
      end
      @annotations=[]
      return nil
    end
    
    def included(base)
      included_modules.each do |mod|
        mod.included(base)
      end
    end
    
  end
end