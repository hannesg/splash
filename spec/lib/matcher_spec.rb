require File.join(File.dirname(__FILE__),"../helper")

describe Splash::Matcher do
  
  describe "matching" do
    
    it "should work in an easy case" do
      
      a = Splash::AttributedStruct.new
      
      a.foo = "blue"
      
      a.bar = 4
      
      Splash::Matcher.cast(
        'foo' => 'blue',
        'bar' => {'$lt' => 5}
      ).matches?(a).should be_true
      
    end
    
    
  end
  
  describe "merging" do
    
    it "should support merging in a trivial case" do
      
      a = Splash::Matcher.new('name'=>'Max')
      b = Splash::Matcher.new('age'=>20)
      
      a_and_b = a.and b
      
      a_and_b.should == Splash::Matcher.new('name'=>'Max','age'=>20)
      
    end
    
    it "should support merging with overlapping attributes" do
      
      a = Splash::Matcher.new('age'=>{'$lt'=>30})
      b = Splash::Matcher.new('age'=>20)
      
      a_and_b = a.and b
      
      a_and_b.should == Splash::Matcher.new('age'=>{'$all'=>[20],'$lt'=>30})
      
    end
    
  end
  
end