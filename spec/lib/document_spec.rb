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


end
