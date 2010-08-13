class ScopeOptions
  
  def self.cast(hsh)
    if hsh.kind_of? self
      return hsh
    end
    return self.new(hsh)
  end
  
  def initialize(hsh=nil)
    @options={:selector=>{},:limit=>-1}
    @options.merge! hsh if hsh
    
    @options.freeze
  end
  
  def merge(options)
    self.class.new(@options.merge(options.to_h))
  end
  
  def to_h
    @options
  end
  
  def selector
    @options[:selector]
  end
  def options
    @options.reject{|key,value| key == :selector}
  end
end