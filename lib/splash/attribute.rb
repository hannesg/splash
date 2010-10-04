# -*- encoding : utf-8 -*-
class Splash::Attribute
  
  include Splash::HasConstraint
  
  NIL_LAMBDA = lambda{ nil }
  
  attr_accessor :persister, :type
  
  def default(&block)
    if block_given?
      @default_block = block
    end
    @default_block.call
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
  
  def persisted_by(*args,&block)
    @persister = Splash::HasAttributes.get_persister(*args, &block)
  end
  
  def read(value)
    @persister.from_saveable(value)
  end
  
  def write(value)
    @persister.to_saveable(value)
  end
  
  def persisted_class
    return @type
  end
  
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
