# -*- encoding : utf-8 -*-
class Splash::AttributedStruct
  
  include Splash::HasAttributes
  
  def initialize(attr={})
    self.attributes.load(attr)
  end
end
