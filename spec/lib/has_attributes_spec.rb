# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::HasAttributes do
  
  describe "declaration" do
    
    it "should look cool and work" do
      
      class User
        
        include Splash::HasAttributes
        
        
        # simple style
        attribute 'name'
        
        # simple with type
        attribute 'friends', Array.of(User)
        
        attribute( 'mails', Array.of(String)) do
          
          default :new
          
        end
        
        attribute 'family', Hash.of(String, User) do
          
          default :new
          
        end
        
      end
      
      User.attributes.should have(4).items
      
      u = User.new
      
      u.name.should be_nil
      
      u.friends.should be_nil
      
      u.mails.should_not be_nil
      u.mails.should be_a(Array.of(String))
      
      u.family.should be_a(Hash.of(String, User))
      
    end
    
  end
  
  it "should support nils" do
    
    class TestUser
      
      include Splash::Document
      
    end
    
    class TestSession
      
      include Splash::HasAttributes
      
      
      attribute "user", TestUser
      
    end
    
    s = TestSession.new
    
    s.user = TestUser.new
    
    s.user = nil
    
    s.user.should be_nil
    
    
  end
  
  it "should support collections" do
    
    class TestSession
      
      include Splash::Document
      
    end
    
    class TestUser
      
      include Splash::Document
      
      attribute( "sessions", Array.of(TestSession) ){
        default :new
      }
      
    end
    
    
    user = TestUser.new
    
    user.sessions << TestSession.new.store!
    user.sessions << TestSession.new.store!
    user.sessions << TestSession.new.store!
    
    user.store!
    
    TestUser.first.sessions.should have(3).items
    
  end
  
  describe "defaults" do
    
    it "should support an easy way to create new instances of the given object" do
      
      class TestThing
      
        include Splash::HasAttributes
        
        attribute 'foo', String do
          
          default &:new
          
        end
        
      end
      
      TestThing.new.foo.should == ''
      
      
      TestThing.attribute('foo').type = Array
      
      TestThing.new.foo.should == []
      
    end
    
    it "should be able to create defaults with args" do
      
      class TestThing
      
        include Splash::HasAttributes
        
        attribute 'zoom', Array do
          
          # a bit counterintuitve ...
          default :new, 4, 2
          
        end
        
      end
      
      TestThing.new.zoom.should == Array.new(4,2)
      
    end
    
    it "should be able to create defaults" do
      
      class TestThing
      
        include Splash::HasAttributes
        
        attribute 'bar', String do
          
          default{ "baz"}
          
        end
        
      end
      
      TestThing.new.bar.should == "baz"
      
    end
    
    
  end
  
end
