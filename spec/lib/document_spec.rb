describe Splash::Document do

  it "should be saved with defaults" do
  
    class DocumentAX
  
      include Splash::Document
      
      attribute 'foo', Numeric do
      
        default{ 100 }
      
      end
  
    end
    
    DocumentAX.new('bla' => 'blub').store!
    DocumentAX.conditions( 'foo' => 100 ).should_not be_empty
    
  end
  
  it "should be able to work around jsonated dbrefs" do
  
    class DocumentBX
  
      include Splash::Document
      
    end
    
    doc = DocumentBX.new('bla' => 'blub').store!
    
    DocumentBX.persister.from_saveable(doc._dbref.to_s).should == doc
    
  end
  
  it "should be able to set values by objectid or dbref" do
  
    class DocumentCX
  
      include Splash::Document
      
    end
    
    class DocumentDX
  
      include Splash::Document
      
      attribute 'object', DocumentCX
      
    end
    
    obj = DocumentCX.create
    
    doc = DocumentDX.new
    
    doc.object = obj._dbref
    
    doc.object.should == obj
    
    doc2 = DocumentDX.new
    
    doc2.object = obj._id
    
    doc2.object.should == obj
    
  
  end


end
