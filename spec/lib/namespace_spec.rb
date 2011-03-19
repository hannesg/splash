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
  
  it "should dereference correctly, even when the class has not yet accessed the collection" do
    
    
    c = Splash::Namespace.default.collection('brxlwopf')
    id = c.insert({
      'name' =>'Hallowed'
    })
    
    class Brxlwopf
      
      include Splash::Document
      
      attribute "name"
      
    end
    
    found = Splash::Namespace.default.dereference(BSON::DBRef.new('brxlwopf',id))
    found.should be_a(Brxlwopf)
    found.name.should == 'Hallowed'
    
  end
  
  describe "naming" do
    
    it "should convert class to collection names" do
      
      ns = Splash::Namespace.default
      
      ns.class_to_collection_name("Consultant").should == "consultant"
      
      ns.class_to_collection_name("FinanceEnquiry").should == "financeEnquiry"
      
      ns.class_to_collection_name("Notification::Request").should == "notification.request"
      
      
    end
    
    
  end
  
  
end