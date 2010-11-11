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
  
  describe Array::Linked do
    
    it "should work in a simple case" do
      
      a = Array::Linked.new([1,2,3])
      b = Array::Linked.new([4,5,6])
      c = Array::Linked.new([7,8,9])
      
      a.successor = b
      b.successor = c
      
      sum = 0
      a.each do |value|
        sum += value
      end
      
      sum.should == 45
      
    end
    
  end
  
end
