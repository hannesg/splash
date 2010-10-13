class Hash
  module WithKnowledgeOfEntries
    
    def kind_of?(other)
      if other < Hash::WithKnowledgeOfEntries
        return true if self.class.entry_class <= other.entry_class and self.class.key_class <= other.key_class
        return self.all? do |key,entry| key.kind_of? other.key_class and entry.kind_of? other.entry_class end
      end
      super
    end
    
    module ClassMethods
    
      attr_reader :key_class, :entry_class
    
      def persister
        Hash::Persister.new(self,self.key_class.persister,self.entry_class.persister)
      end
    
    end
    
  end
  
  def self.of(key_klass, entry_klass)
    Class.new(self){
      
      @key_class = key_klass
      @entry_class = entry_klass
      
      include WithKnowledgeOfEntries
      extend WithKnowledgeOfEntries::ClassMethods
      
    }
  end
end