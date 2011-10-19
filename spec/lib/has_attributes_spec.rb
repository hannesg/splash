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
    
    Tweedledum.should respond_to(:_attribute_size_type)
    
    Tweedledee.should_not respond_to(:_attribute_size_type)
    
    
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
      
      u.name.should_not be_given
      
      u.friends.should_not be_given
      
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
      
      attribute( 'comments', Hash.of(User2, String) ) do
        
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
  
  describe 'setter' do
  
    it 'should work' do
      
      class AttributeWithSetters
      
        include Splash::HasAttributes
        
        attribute 'number', Integer do
        
          setter{ |value| value.to_i }
        
        end
        
      end
      
      a = AttributeWithSetters.new
      
      a.number = "1337"
      
      a.number.should == 1337
      
    end
  
  end
  
  describe 'updating' do
    it 'should generate updates' do
      
      class HashWithUnpresentKeys < Hash
        
        def present_keys
          self.keys - ['evil_key']
        end
        
        def [](key)
          raise 'You asked for the evil key!' if key == 'evil_key'
          super
        end
        
      end
      
      class Updateable1
        
        include Splash::HasAttributes
      
      end
      
      h = HashWithUnpresentKeys.new
      h.update({'name'=>'Legion','evil_key'=>666,'position'=>{'x'=>1337,'y'=>56}})
      
      u1 = Updateable1.from_raw(h)
      u1.attributes.updates.should == {'$set'=>{},'$unset'=>{}}
      u1.name = 'Legion!'
      u1.spirits = 2000
      u1.position = NA
      u1.attributes.updates.should == {'$set'=>{'name'=>'Legion!','spirits'=>2000},'$unset'=>{'position'=>1}}
      
    end
  
    it 'should work' do
      class Updateable2
        
        include Splash::Documentbase
        include Splash::HasCollection
        include Splash::HasAttributes
        
      end
      
      u1 = Updateable2.new('hallo'=>'du')
      
      u1.store!
      
      u1 = Updateable2.first
      
      u1.save!
      
      u1.tschuess = 'du'
      
      u1.save!
      
      Updateable2.first.tschuess.should == 'du'
      
      u1.hallo = ::NA
      u1.save!
      
      Updateable2.first.hallo.should_not be_given
      
    end
    
    it 'should work with lazy fields' do
      class Updateable3
        
        include Splash::Documentbase
        include Splash::HasCollection
        include Splash::HasAttributes
        
        lazy! 'lazy'
        
      end
      class Updateable4
        
        include Splash::Documentbase
        include Splash::HasCollection
        include Splash::HasAttributes
        
        eager! 'hallo'
        fieldmode! :include
        
      end
      
      
      u1 = Updateable3.new('hallo'=>'du','lazy'=>'looooooooooong text')
      u1.store!
      
      u2 = Updateable4.new('hallo'=>'du','lazy'=>'looooooooooong text')
      u2.store!
      
      u1 = Updateable3.first
      u1.tschuess = 'du'
      u1.save!
      
      u2 = Updateable4.first
      u2.tschuess = 'du'
      u2.save!
      
      Updateable3.first.tschuess.should == 'du'
      Updateable4.first.tschuess.should == 'du'
    end
    
  end
  
  describe 'threading' do
  
    it 'could maybe work' do
      
      class ThreadedObject1
      
        def initialize
          Thread.pass
          sleep(rand()*1000)
          Thread.pass
        end
      end
      
      class ThreadedDocument1
      
        include Splash::HasAttributes
        
        attribute 'object', ThreadedObject1 do
          default :new
        end
        
      end
      
      ThreadedObject1.should_receive(:new).exactly(100).times
      
      a = (1..100).map do ThreadedDocument1.new end
      threads = []
      100.times do
        threads << Thread.new {
          a.each &:object
        }
      end
      threads.each &:join
      
    end
  end
  
  describe 'constrainig' do
  
    it "should work" do
    
      class AttributedConstraintedDocument1
      
        include Splash::HasAttributes
        include Splash::HasConstraints
        include Splash::Constraint::AttributeInterface
        
        
        
        attribute 'bla' do
          
          validate do | value |
          
            errors << _.strange_error if value == 5
          
          end
          
        end
        
        attribute 'blub' do 
        
          validate do | value, errors |
          
            errors << errors._.strange_error if value == 5
          
          end
        
        end
        
        attribute 'blob' do
        
          validate_not_nil
        
        end
      
      end
      
      AttributedConstraintedDocument1.new('bla' => 4, 'blub' => 6, 'blob' => true).validate.should be_valid
      
      doc = AttributedConstraintedDocument1.new('bla' => 5,'blub' => 5)
      result = doc.validate
      result.should_not be_valid
      
      result['bla'].errors.should have(1).items
      result['blub'].errors.should have(1).items
      result['blob'].errors.should have(1).items
    
    end
  
  end
  
end
