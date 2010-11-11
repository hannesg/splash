# -*- encoding : utf-8 -*-
class Splash::Attribute
  
  def default(fn=nil,*args,&block)
    if block_given?
      set('default'){ block }
    elsif !fn.nil?
      set('default'){ lambda{self.send(fn,*args)} }
    else
      return self.type.instance_eval &(get('default'))
    end
  end
  
  def get(key)
    @class.send("attribute_#{@name}_#{key}")
  end
  
  def set(key,&block)
    @setter.call("attribute_#{@name}_#{key}",&block)
  end
  
  def initialize(klass,name)
    @class, @name = klass, name
    @setter = (class << @class; method(:define_method); end)
  end
  
  def hmmmm(t=Object,&block)
    self.type = t
    instance_eval &block if block_given?
  end
  
  def type= t
    self.persister = t.persister
    @type = t
    set('type'){ t }
  end
  
  def type
    @type ||= get('type')
  end
  
  def persister=(t)
    @persister = t
    set('persister'){ t }
  end
  
  alias_method :persisted_by, :persister=
  
  def persister
    @persister ||= get('persister')
  end
  
  # persisting interface
  def from_saveable(value)
    persister.from_saveable(value)
  end
  
  def to_saveable(value)
    persister.to_saveable(value)
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
