# -*- encoding : utf-8 -*-
class Splash::Constraint::In
  
  include Splash::Constraint
  
  def initialize(collection,desc="")
    @collection = collection
    super(desc)
  end
  
  def accept?(value)
    return value.nil? || collection.include?(value)
  end
end
