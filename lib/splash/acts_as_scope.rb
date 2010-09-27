module Splash
  module ActsAsScope
    include QueryInterface
    
    
    # the following methods have to be defined
    # when including this Module:
    # - collection
    # - scope_root
    
    
    def scope_options
      @scope_options ||= Splash::Scope::Options.new
    end
    
    def query(options)
      Scope.new(self,scope_options.merge(options))
    end
    
    def dup
      
    end
    
    def all
      clone
    end
    
    def each(&block)
      self.clone.scope_cursor.each do |o|
        yield Saveable.load(o,self)
      end
      self
    end
    
    def to_a
      result = []
      each do |object|
        result << object
      end
      return result
    end
    
    def has_next?
      scope_cursor.has_next?
    end
    
    def next_document
      nd = scope_cursor.next_document
      return nil if nd.nil?
      return Saveable.load(nd,self)
    end
    
    def first
      self.clone.limit(1).next_document
    end
    
    def clone
      return Scope.new(self.scope_root,scope_options.dup)
    end
    
    def next_raw_document
      scope_cursor.next_document
    end
    
    def inspect
      scope_options.inspect
    end

=begin
    def finish!
      self.scope_cursor
      self
    end
    
    def finished?
      !@scope_cursor.nil?
    end
    
    def reset!
      self.unset_scope_cursor
      self
    end
=end
    
    def count
      self.clone.scope_cursor.count
    end
    
    def scope_root?
      false
    end
    
    def <<(object)
    end

    protected
      def scope_cursor()
        @scope_cursor ||= find!(scope_options.selector,scope_options.options)
      end
      
      def unset_scope_cursor()
        @scope_cursor=nil
      end
      
      def query!(options)
        @scope_options = scope_options.merge(options)
      end
    
      def find!(selector,options)
        selector["Type"]=self.scope_root.to_s
        self.scope_root.collection.find(selector,options)
      end
  end
end