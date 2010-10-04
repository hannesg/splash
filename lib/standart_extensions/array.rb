# -*- encoding : utf-8 -*-
class Array
  
  # 'first' should not be so alone
  def rest
    self[1..-1] || []
  end
  
end