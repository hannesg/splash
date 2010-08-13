require File.join(File.dirname(__FILE__),"../helper")

describe Splash::HasConstraint do
  
  describe "declaration" do
    
    it "should work in a trivial case" do
      
      class Field
        
        include Splash::HasConstraint
        
      end
      
      f = Field.new
      
      f.constraint.should_not be_nil
      
      f.constraint.accept?(nil).should be_true
      
    end
    
    it "should give the power to write simple constraints fast" do
      
      class Field
        
        include Splash::HasConstraint
        
      end
      
      f = Field.new
      
      f.constraint.create "should not be nil" do |value|
        !value.nil?
      end
      
      f.constraint.create "should be a string with 5 to 10 chars" do |value|
        value.kind_of?(String) && (5..10).include?(value.length)
      end
      
      f.constraint.should have(2).items
      
      f.constraint.accept?(nil).should be_false
      
      f.constraint.accept?("aaa").should be_false
      
      f.constraint.accept?("aaaaa").should be_true
      
    end
    
  end
  
end