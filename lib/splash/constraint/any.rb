# -*- encoding : utf-8 -*-
class Splash::Constraint::Any < Set
  
  include Splash::Constraint
  include Splash::ActsAsCollection.of(Splash::Constraint)
  
  def accept?(value)
    self.all? do |constr|
      constr.accept?(value)
    end
  end
  
  
end
