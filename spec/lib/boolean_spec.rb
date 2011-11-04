describe Splash::Boolean do

  it "should be saveable" do
  
    Splash::Boolean.to_saveable(true).should == true
    
    Splash::Boolean.to_saveable(false).should == false
    
    Splash::Boolean.to_saveable(nil).should == false
    
    Splash::Boolean.to_saveable(Object.new).should == true
  
  end

  it "should be loadable" do
  
    Splash::Boolean.from_saveable(true).should == true
    
    Splash::Boolean.from_saveable(false).should == false
    
    Splash::Boolean.from_saveable(nil).should == false
    
    Splash::Boolean.from_saveable(Object.new).should == true
    
    Splash::Boolean.from_saveable(true.to_s).should == true
    
    Splash::Boolean.from_saveable(false.to_s).should == false
    
  end

end
