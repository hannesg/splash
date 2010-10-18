# -*- encoding : utf-8 -*-
class Splash::Attribute
  
  NIL_LAMBDA = lambda{ nil }
  
  attr_accessor :persister, :type
  
  def default(fn=nil,*args,&block)
    if block_given?
      @default_block = block
    elsif !fn.nil? 
      @default_block = lambda{ self.send(fn,*args) }
    else
      type.instance_eval &@default_block
    end
  end
  
  def initialize(t=Object,&block)
    self.type = t
    @default_block = NIL_LAMBDA
    instance_eval &block if block_given?
  end
  
  def type= t
    @persister = t.persister
    @type = t
  end
  
  def persisted_by(p)
    @persister = p
  end
  
  # persisting interface
  def read(value)
    @persister.from_saveable(value)
  end
  
  def write(value)
    @persister.to_saveable(value)
  end
  
  # type interface
  def missing
    self.default
  end
  
  def writeable?
    true
  end
  
  def initial_value
    return type.initial_value if type && type.respond_to?(:initial_value)
    ::NotGiven
  end
  
  def before_write(value)
    return type.before_write(value) if type && type.respond_to?(:before_write)
    value
  end
  
end
