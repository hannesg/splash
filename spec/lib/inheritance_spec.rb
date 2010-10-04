# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe "inheritance" do
  
  it "should generate normal methods" do
    
    class A
      
      merged_inheritable_attr :a
      merged_inheritable_attr :b,"b"
      
    end
    
    A.respond_to?(:a).should be_true
    A.respond_to?(:b).should be_true
    
    A.b.should == "b"
    
    A.all_b.should == "b"
    
    
  end
  
  it "should generate inheritable methods" do
    
    class A
      
      merged_inheritable_attr :a
      merged_inheritable_attr :b,"b" do |a,b|
        a + b
      end
      
    end
    
    class B < A
      
    end
    
    class C < B
      merged_inheritable_attr :c
    end
    
    A.a << 1
    
    B.respond_to?(:a).should be_true
    B.respond_to?(:b).should be_true
    
    B.b = "c"
    
    B.a << 2
    
    B.all_b.should == "cb"
    
    C.all_b.should == "bcb"
    
    C.a << 3
    
    A.a.should have(1).item
    A.all_a.should have(1).item
    
    B.a.should have(1).item
    B.all_a.should have(2).items
    
    C.a.should have(1).item
    C.all_a.should have(3).items
    
  end
  
end
