module Splash
  class Scope
    
    autoload_all File.join(File.dirname(__FILE__),'scope')
    
    include Splash::ActsAsScope

    def initialize(parent,options)
      @parent_scope=parent.scope_root
      @scope_options=options
    end
    
    def scope_root?
      false
    end
    
    def scope_root
      @parent_scope
    end
    
    def respond_to?(meth)
      load_scope_extensions!
      super
    end
    
    private
      def load_scope_extensions!
        unless @scope_extesions_loaded
          @scope_options.extensions.each do |mod|
            self.extend(mod)
          end
          @scope_extesions_loaded = true
          return true
        end
        return false
      end
      def method_missing(meth,*args,&block)
        if load_scope_extensions!
          return self.send(meth,*args,&block)
        end
        super
      end
    
  end
end