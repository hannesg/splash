class Array
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
end