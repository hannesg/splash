module Splash::ActsAsScopeRoot
  include Splash::ActsAsScope
  
  def scope_root
    self
  end
  def scope_root?
    true
  end
end