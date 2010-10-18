# -*- encoding : utf-8 -*-
module Splash::Embed
  
  class Persister
    def to_saveable(value)
      return nil if value.nil?
      return Splash::Saveable.wrap(value)
    end
    
    def from_saveable(value)
      return nil if value.nil?
      return Splash::Saveable.load(value,@base_class)
    end
    
    def initialize(klass)
      @base_class = klass
    end
    
  end
  
  include Splash::HasAttributes
  include Splash::Saveable
  #include Splash::Validates
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      included_modules.each do |mod|
        begin
          mod.included(base)
        rescue NoMethodError
        end
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
      Splash::Embed::Persister.new(self.define{})
    end
  end
  
  module ClassMethods
    def persister
      Splash::Embed::Persister.new(self)
    end
  end
  
end
