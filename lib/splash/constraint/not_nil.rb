# -*- encoding : utf-8 -*-
class Splash::Constraint::NotNil
  
  include Splash::Constraint
  
  def accept?(value)
    !value.nil?
  end
  
end
