class Hash
  class Persister

    attr_accessor :key_persister, :entry_persister

    def from_saveable(val)
      return nil if val.nil?
      nu=@base_class.new
      val.inject(nu){|memo,(key,entry)|
        memo[ @key_persister.from_saveable(key) ] = @entry_persister.from_saveable(entry)
        memo
      }
    end
    
    def to_saveable(val)
      return nil if val.nil?
      val.inject({}){|memo,(key,entry)|
        memo[ @key_persister.to_saveable(key) ] = @entry_persister.to_saveable(entry)
        memo
      }
    end
    
    def initialize(klass, key_persister, entry_persister)
      @base_class = klass
      @key_persister = key_persister
      @entry_persister = entry_persister
    end
    
  end
end