class Array::Linked < Array
  
  attr_accessor :successor
  
  def each(&block)
    super
    successor.each(&block) if successor
  end
  
  def include?(value)
    super or (successor and successor.include? value)
  end
  
  def [](key)
    k = key - self.size
    if successor and k > 0
      return successor[k]
    end
    super
  end
  
  def push(value)
    if successor
      successor.push(value)
      return self
    end
    super
  end
  
  def pop
    if successor
      return successor.pop
    end
    super
  end
  
end