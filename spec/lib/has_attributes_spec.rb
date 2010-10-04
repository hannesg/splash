# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::HasAttributes do
  
  describe "declaration" do
    
    it "should look cool and work" do
      
      class User
        
        include Splash::HasAttributes
        
        
        # simple style
        def_attribute 'name'
        
        # simple with type
        def_attribute 'friends', Splash::Collection.of(User)
        
        def_attribute( 'mails', Splash::Collection.of(String)) do
          
          default{
            Splash::Collection.of(String).new
          }
          
        end
        
      end
      
      User.attributes.should have(3).items
      
      u = User.new
      
      u.name.should be_nil
      
      u.friends.should be_nil
      
      u.mails.should_not be_nil
      u.mails.should be_a(Splash::Collection.of(String))
      
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
      
      attribute( "sessions", Splash::Collection.of(TestSession) ){
        default{ Splash::Collection.of(TestSession).new }
      }
      
    end
    
    
    user = TestUser.new
    
    user.sessions << TestSession.new.store!
    user.sessions << TestSession.new.store!
    user.sessions << TestSession.new.store!
    
    puts user.to_saveable.inspect
    
    user.store!
    
    TestUser.first.sessions.should have(3).items
    
  end
  
end
