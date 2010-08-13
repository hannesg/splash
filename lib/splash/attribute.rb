class Splash::Attribute
  
  include ::Humanized
  include Splash::HasConstraint
  
  attr_accessor :persister, :type, :default
  
  def initialize(t=nil,&block)
    self.type=t if t
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
    if self.default
      self.default.clone
    else
      nil
    end
  end
  
end