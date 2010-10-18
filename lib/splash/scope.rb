# -*- encoding : utf-8 -*-
module Splash
  class Scope
    
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
    
  end
end
