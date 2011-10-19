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


end
