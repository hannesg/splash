# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::Namespace do
  
  it "should derefence correctly" do
    
    class Something
      
      include Splash::Document
      
      attribute "name"
      
    end
    
    
    a = Something.new('name'=>'A').store!
    ['b','c','d','e','f'].each do |c|
      
      Something.new('name'=>c).store!
      
    end
    z = Something.new('name'=>'Z').store!
    
    
    
    
    Something.namespace.dereference(BSON::DBRef.new(Something.collection.name , a._id)).should == a
    
    
    Something.namespace.dereference(BSON::DBRef.new(Something.collection.name , z._id)).should == z
    
  end
  
  
  it "should get the correct class, right from the start" do
    
    class Brxlwupf
      
      include Splash::HasCollection
      
    end
    
    Brxlwupf.namespace.class_for('brxlwupf').should == Brxlwupf
    
    
    
  end
  
  describe "naming" do
    
    it "should convert class to collection names" do
      
      ns = Splash::Namespace.default
      
      ns.class_to_collection_name("Consultant").should == "consultant"
      
      ns.class_to_collection_name("FinanceEnquiry").should == "finance_enquiry"
      
      ns.class_to_collection_name("Notification::Request").should == "notification.request"
      
      
    end
    
    
  end
  
  
end