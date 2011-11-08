describe "uniqueness" do


  it "should be provided" do
  
    col = Splash::Namespace.default.collection('unique')
    
    col.ensure_index([['x',Mongo::ASCENDING]], :unique=>true)
    
    col.insert({'x'=>1},{:safe=>true})
    
    lambda{ col.insert({'x'=>1},{:safe=>true}) }.should raise_error(Mongo::Error::DuplicateKey)
    
    col.insert({'x'=>2},{:safe=>true})
    
    lambda{ col.update({'x'=>2},{'x'=>1},{:safe=>true}) }.should raise_error(Mongo::Error::DuplicateKey)
  
  end
  
  it "should be provided for documents" do
  
    class UniqueDocument
    
      include Splash::Document
      
      collection.ensure_index([['x',Mongo::ASCENDING]], :unique=>true)
      
      self.safe_on_keys = ['x']
    
    end
    
    UniqueDocument.create({'x'=>1})
    
    lambda{ UniqueDocument.create({'x'=>1}) }.should raise_error(Mongo::Error::DuplicateKey)
    
    ud = UniqueDocument.create({'x'=>2})
    
    lambda{ ud.x = 1; ud.store! }.should raise_error(Mongo::Error::DuplicateKey)
    
  end

end
