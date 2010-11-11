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

describe "Time" do
  
  it "should be saved and loaded" do
    
    class TestPost
      
      include Splash::Document
      
      attribute "post_time"
      
    end
    
    TestPost.new("post_time" => Time.local(2010,10,10,10,10,10)).store!
    
    TestPost.first.post_time.should == Time.local(2010,10,10,10,10,10)
    
    
  end
  
  it "should be saved and loaded with given type" do
    
    class TestPost2
      
      include Splash::Document
      
      attribute "post_time", Time
      
    end
    
    TestPost2.new("post_time" => Time.local(2010,10,10,10,10,10)).store!
    
    TestPost2.first.post_time.should == Time.local(2010,10,10,10,10,10)
    
    
  end
  
  describe "created at" do
    
    it "should be set on creation" do
      
      class TestPost3
        
        include Splash::Document
        
        attribute "created_at", Splash::CreatedAt do
          default{ Time.now }
        end
        attribute "updated_at", Splash::UpdatedAt do
          default{ Time.now }
        end
        
      end
      
      TestPost3.new().store!
      
      TestPost3.first.created_at.should_not be_nil
      TestPost3.first.created_at.should be_a(Time)
    
    end
    
    it "should not be changed on update" do
      
      TestPost3.new.store!
      
      tp = TestPost3.first
      date = tp.created_at
      
      tp.x = :y
      
      tp.store!
      # mongodb only stores milli seconds, not micro seconds
      TestPost3.first.created_at.should be_close(date,0.001)
    
    end
    
  end
  
  describe "updated at" do
    
    it "should be set on creation" do
      
      TestPost3.new.store!
      
      TestPost3.first.updated_at.should_not be_nil
      TestPost3.first.updated_at.should be_a(Time)
    
    end
    
    it "should be changed on update" do
      
      pending "not developed yet"
      
      TestPost3.new.store!
      
      tp = TestPost3.first
      date = tp.updated_at
      
      tp.x = :y
      
      tp.store!
      TestPost3.first.updated_at.should > date
    
    end
    
  end
  

end