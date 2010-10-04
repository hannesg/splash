# -*- encoding : utf-8 -*-
module Splash::Embed
  
  include Splash::HasAttributes
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
  end
  
  module ClassMethods
    def persister
      Splash::Saveable::EmbedPersister
    end
    
    def from_saveable(args)
      new(args)
    end
  end
  
  def initialize(args={})
    self.attributes.load(args)
  end
    def to_saveable
      attributes.raw
    end
end
