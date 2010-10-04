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
  
  def initialize(t=nil,&block)
    self.type=t if t
    @default_block = NIL_LAMBDA
    instance_eval &block if block_given?
  end
  
  def type= t
    @persister = Splash::HasAttributes.get_persister(t)
    @type = t
  end
  
  def persisted_by(*args,&block)
    @persister = Splash::HasAttributes.get_persister(*args, &block)
  end
  
  def read(value)
    return value unless @persister
    @persister.read(value)
  end
  
  def write(value)
    return value unless @persister
    @persister.write(value)
  end
  
  def persisted_class
    return Object unless @persister
    @persister.persisted_class
  end
  
  def missing()
    self.default
  end
  
end
