# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Array do
  
  describe "of class" do
  
    it "should support class integration" do
      
      class Friend
        
      end
      
      class FriendList < Array.of(Friend)
        
      end
      
      FriendList.should < Array
      
      fl = FriendList.new
      
      #fl.respond_to?(:create).should be_true
      
      #fl.create
      
      #fl.should have(1).item
      
    end
    
    it "should support the collection class" do
      
      class Friend
        
      end
      
      fl = Array.of(Friend).new
      
      #fl.respond_to?(:create).should be_true
      
      #fl.create
      
      #fl.should have(1).item
      
    end
    
    it "should support comparison" do
      
      
      class User
        
      end
      
      class Admin < User
        
      end
      
      flu = Array.of(User).new
      
      fla = Array.of(Admin).new
      
      flu.should be_a(Array.of(User))
      
      fla.should be_a(Array.of(User))
      
    end
  
  end
  
end
