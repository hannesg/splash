require File.join(File.dirname(__FILE__),"../helper")

describe Splash::Saveable do
  
  it "should implement a meaningful equal operator" do
    
    class Xy
      
      include Splash::Document
      
    end
    
    original = Xy.new('xkcd'=>'rocks!')
    
    original.store!
    
    Xy.to_a.first.should == original
    
  end
  
end