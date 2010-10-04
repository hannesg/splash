# -*- encoding : utf-8 -*-
module Splash::Callbacks
  
  protected
  def run_callbacks(name,*args)
    regex = Regexp.new("^#{Regexp.escape name.to_s}"_)
    self.methods.each do |meth|
      if meth.to_s ~= regex
        self.send(meth,*args)
      end
    end
  end
  
  def with_callbacks(name,*args)
    run_callbacks('before_' + name.to_s,*args)
    result = yield
    run_callbacks('after_' + name.to_s,*args)
    return result
  end
  
  module ClassMethods
    
    def with_callbacks(fn)
      def ___callbacked()
        
      end
      alias_method(fn +'_without_callbacks',fn)
      
      self.define_method(fn+'_with_callback') do
        fn
      end
    end
    
    define_annotation :with_callbacks
    
  
end
