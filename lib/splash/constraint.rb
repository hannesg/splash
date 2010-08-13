module Splash::Constraint
  
  attr_reader :description
  
  autoload :Any, File.join( File.dirname(__FILE__), 'constraint/any' )
  autoload :All, File.join( File.dirname(__FILE__), 'constraint/all' )
  autoload :NotNil, File.join( File.dirname(__FILE__), 'constraint/not_nil' )
  autoload :In, File.join( File.dirname(__FILE__), 'constraint/in' )
  
  class Simple
    
    include Splash::Constraint
    
    def initialize(descr,&block)
      @description = descr
      @block = block
    end
    
    def accept?(value)
      return @block.call(value)
    end
    
  end
  
  def self.new(*args,&block)
    if self == Splash::Constraint
      return Simple.new(*args,&block)
    end
    super
  end
  
  def self.and(*args)
    if args.length == 0
      return Splash::Constraint::All.new
    elsif args.length == 1
      return args.first
    else
      result = Splash::Constraint::All.new
      args.each do |constr|
        if constr.kind_of? Splash::Constraint::All
          result += constr
        else
          result << constr
        end
        
      end
      return result
    end
  end
  
  def not_accepting(value)
    return self unless self.accept?(value)
  end
  
  def initialize(descr)
    @description = descr
    super()
  end
  
  alias_method :to_s, :description
  
end