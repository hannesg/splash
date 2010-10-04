# -*- encoding : utf-8 -*-
class Object
  
  # most object can persist themself
  def self.to_saveable(obj)
    return obj
  end
  
  def self.from_saveable(obj)
    return obj
  end
  
end
