class Splash::Collection < Array
  include Splash::ActsAsCollection
  
  COLLECTION_CLASSES = {}
  
  def self.of(klass)
    
    return COLLECTION_CLASSES[klass] if COLLECTION_CLASSES.key? klass
    
    c = Class.new(self)
    c.instance_eval do
      @collection_class = klass
    end
    
    COLLECTION_CLASSES[klass] = c
    return c
  end
  

  class Persister < Splash::Persister

    def read(val)
      return nil if val.nil?
      nu=persisted_class.new
      val.inject(nu){|memo,e|
        memo << @persister.read(e)
        memo
      }
    end
    
    def write(val)
      return nil if val.nil?
      val.inject([]){|memo,e|
        memo << @persister.write(e)
        memo
      }
    end
    
    def persist_class(col)
      @persister=Splash::HasAttributes.get_persister(col.collection_class)
      super
    end
    
  end
  
  class << self
    def persister
      return Splash::Collection::Persister
    end
  end

end