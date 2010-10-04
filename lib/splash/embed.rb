# -*- encoding : utf-8 -*-
module Splash::Embed
  
  class Persister
    def to_saveable(value)
      return nil if value.nil?
      return Saveable.wrap(value)
    end
    
    def from_saveable(value)
      return nil if value.nil?
      return Saveable.load(value)
    end
  end
  
  
  include Splash::HasAttributes
  include Splash::Saveable
  include Splash::Validates
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      included_modules.each do |mod|
        mod.included(base)
      end
    end
    
    def define(&block)
      c=Class.new()
      mod = self
      c.instance_eval do
        include mod
      end
      c.class_eval(&block)
      c
    end
    
    def persister
      Splash::Embed::Persister
    end
  end
  
  module ClassMethods
    def persister
      Splash::Embed::Persister
    end
  end
  
end
