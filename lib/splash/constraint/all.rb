# -*- encoding : utf-8 -*-
class Splash::Constraint::All < Set
  
  include Splash::Constraint
  include Splash::ActsAsCollection.of(Splash::Constraint)
  
  def accept?(value)
    self.all? do |constr|
      constr.accept?(value)
    end
  end
  
  def not_accepting(value)
    result = Splash::Constraint::All.new
    self.each do |constr|
     result << constr unless constr.accept?(value)
    end
    return result
  end
  
  def initialize
    super("all!")
  end
  
end
