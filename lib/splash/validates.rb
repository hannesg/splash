require "set"
module Splash::Validates
  
  class Invalid < Exception
    
    attr_reader :object, :validators
    
    def initialize(obj)
      super
      self.object = obj
      self.validators = Set.new
    end
    
  end
  
  class << self
    def included(base)
      base.instance_eval do
        merged_inheritable_attr :validators,Set.new
      end
      base.extend(ClassMethods)
    end
  end
  
  module ClassMethods
    def validate(*args,&block)
      if args.first.respond_to? :valid?
        validators << validator
      end
      validators << Splash::Validator.new(*args,&block)
    end
  end
  
  def valid?
    validators = self.class.all_validators
    
    validators.sort! do |a,b|
      if b.depends.include? a.field
        -1
      elsif a.depends.include? b.field
        1
      else
        0
      end
    end
    
    return validators.all? do |validator|
      validator.valid?(self)
    end
  end
  
  def raise_if_invalid
    v = Invalid.new(self)
    
    validators = self.class.all_validators
    
    validators.sort! do |a,b|
      if b.depends.include? a.field
        -1
      elsif a.depends.include? b.field
        1
      else
        0
      end
    end
    
    validators.each do |validator|
      v.validators << validator unless validator.valid?(self)
    end
    
    raise v if v.validators.size > 0
  end
  
  
end