describe "uniqueness" do


  it "should be provided" do
  
    col = Splash::Namespace.default.collection('unique')
    
    col.ensure_index([['x',Mongo::ASCENDING]], :unique=>true)
    
    col.insert({'x'=>1},{:safe=>true})
    
    lambda{ col.insert({'x'=>1},{:safe=>true}) }.should raise_error(Mongo::Error::DuplicateKey)
    
    col.insert({'x'=>2},{:safe=>true})
    
    lambda{ col.update({'x'=>2},{'x'=>1},{:safe=>true}) }.should raise_error(Mongo::Error::DuplicateKey)
  
  end

end
