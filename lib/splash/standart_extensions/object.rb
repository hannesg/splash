class Object
  
  def to_bson
    self
  end
  
  def persister
    Splash::Persister
  end
  
end