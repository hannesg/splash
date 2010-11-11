# -*- encoding : utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    (c) 2010 by Hannes Georg
#
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::HasAttributes do
  
  it 'should work' do
    
    class Tweedledum
    
      include Splash::HasAttributes
    
      attribute 'size', Float do
        
        default{ 13412.234 }
        
      end
    
    end
    
    class Tweedledee
    
      include Splash::HasAttributes
    
    end
    
    Tweedledum.should respond_to(:attribute_size_type)
    
    Tweedledee.should_not respond_to(:attribute_size_type)
    
    
  end
  
  
  describe "declaration" do
    
    it "should look cool and work" do
      
      class HASUser
        
        include Splash::HasAttributes
        
        
        # simple style
        attribute 'name'
        
        # simple with type
        attribute 'friends', Array.of(HASUser)
        
        attribute( 'mails', Array.of(String)) do
          
          default :new
          
        end
        
        attribute('family', Hash.of(String, HASUser) ) do
          
          default :new
          
        end
        
      end
      
      u = HASUser.new
      
      u.name.should be_nil
      
      u.friends.should be_nil
      
      u.mails.should_not be_nil
      u.mails.should be_a(Array.of(String))
      
      u.family.should be_a(Hash.of(String, HASUser))
      
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
  
  it "should support hashes" do
    
    class User2
      
      include Splash::Document
      
      attribute( 'comments', Hash.of(User2, String) )do
        
        default :new
        
        persisted_by Hash::Persister.new(type,User2.persister(:by_id_string),String.persister)
        
      end
      
      
      
    end
    
    u1 = User2.new.store!
    u2 = User2.new.store!
    u3 = User2.new.store!
    
    u1.comments[u2] = "nice friend"
    u1.comments[u3] = "bad guy"
    u1.store!
    
    u1_clone = User2.conditions('_id'=>u1._id).first
    
    u1_clone.comments[u2].should == "nice friend"
    
    u1_clone.comments[u3].should == "bad guy"
    
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
        
        attribute('zoom', Array) do
          
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
