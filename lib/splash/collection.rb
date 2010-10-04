# -*- encoding : utf-8 -*-
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
  

  class Persister

    attr_accessor :entry_persister

    def from_saveable(val)
      return nil if val.nil?
      nu=@base_class.new
      val.inject(nu){|memo,e|
        memo << @entry_persister.from_saveable(e)
        memo
      }
    end
    
    def to_saveable(val)
      return nil if val.nil?
      val.inject([]){|memo,e|
        memo << @entry_persister.to_saveable(e)
        memo
      }
    end
    
    def initialize(klass, entry_persister)
      @base_class = klass
      @entry_persister = entry_persister
    end
    
  end
  
  class << self
    def persister
      return Splash::Collection::Persister.new(self, @collection_class.persister)
    end
  end

end
