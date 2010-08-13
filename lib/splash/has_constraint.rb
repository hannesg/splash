require "set"

module Splash::HasConstraint
  
  def constraint
    @constraint ||= Splash::Constraint::All.new
  end
  
end