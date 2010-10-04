class Class
  
  def self_and_superclasses
    k = self
    while k
      yield k
      k = k.superclass
    end
  end
  
end