class Array
  
  module WithKnowledgeOfEntries
    
    def kind_of?(other)
      if other < Array::WithKnowledgeOfEntries
        return true if self.class.entry_class <= other.entry_class
        return self.all? do |entry| entry.kind_of? other.entry_class end
      end
      super
    end
    
    module ClassMethods
    
      attr_reader :entry_class
    
      def persister
        Array::Persister.new(self,self.entry_class.persister)
      end
    
    end
    
  end
  
  def self.of(klass)
    Class.new(self){
      
      @entry_class = klass
      
      include WithKnowledgeOfEntries
      extend WithKnowledgeOfEntries::ClassMethods
      
    }
  end
  
end