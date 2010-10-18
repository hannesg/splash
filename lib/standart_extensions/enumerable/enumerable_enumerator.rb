module Enumerable
  
  class EnumerableEnumerator
    
    include Enumerable
    
    def initialize(objects, method = :each, *)
      @objects = objects
      @method = method
    end
    
    def each(&block)
      raise ArgumentError, 'each requires a block' unless block_given?
      @objects.each do |object|
        Enumerator.new(object,@method).each(&block)
      end
    end
    
  end
  
  
end