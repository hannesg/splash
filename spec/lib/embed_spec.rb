# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::Embed do
  
  it "should be saveable as document attribute" do
    
    class ICQ
      
      include Splash::Embed
      
      attribute "uin"
      
    end
    
    
    class Customer
      
      include Splash::Document
      
      attribute 'icq', ICQ
      
      attribute 'friends', Array.of(ICQ) do
        
        default &:new
        
      end
      
    end
    
    c = Customer.new( 'icq' => ICQ.new('uin'=>1337) )
    
    c.friends << ICQ.new('uin' => 666)
    c.friends << ICQ.new('uin' => 888)
    
    c.store!
    
    
  end
  
end