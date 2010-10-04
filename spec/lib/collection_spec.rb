# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::ActsAsCollection do
  
  it "should support class integration" do
    
    class Friend
      
    end
    
    class FriendList < Array
      
      include Splash::ActsAsCollection.of(Friend)
      
    end
    
    FriendList.should < Splash::ActsAsCollection
    
    fl = FriendList.new
    
    fl.respond_to?(:create).should be_true
    
    fl.create
    
    fl.should have(1).item
    
  end
  
  it "should support the collection class" do
    
    class Friend
      
    end
    
    fl = Splash::Collection.of(Friend).new
    
    fl.respond_to?(:create).should be_true
    
    fl.create
    
    fl.should have(1).item
    
  end
  
  it "should support comparison" do
    
    
    class User
      
    end
    
    class Admin < User
      
    end
    
    fl = Splash::Collection.of(User).new
    
    fl.should be_a(Splash::Collection.of(User))
    
    
  end
  
  
end
