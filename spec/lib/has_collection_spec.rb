# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::HasCollection do
  
  it "should support setting the collection" do
    
    class HasCollectionClass
      
      include Splash::HasCollection
      
    end
    
    c = HasCollectionClass.collection
    
    HasCollectionClass.collection = HasCollectionClass.namespace.collection('old_has')
    
    HasCollectionClass.collection.should_not == c
    
  end
  
  it "should be usable bare" do
    
    pending( "not fully developed yet" )
    
    class HashWithCollection < Hash
      
      include Splash::HasCollection
      
    end
    
    h = HashWithCollection['xy',123]
    
    h.store!
    
    #HashWithCollection.find
    
    
    
  end
  
  
end