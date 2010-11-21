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

describe Splash::Lazy do
  
  it "should fetch a given value" do
    
    class LazyTestHash1 < Hash
      
      include Splash::HasCollection
      
      def _id
        self["_id"]
      end
      
      def _id=(value)
        self["_id"]=value
      end
      
    end
    
    lh = LazyTestHash1.new
    
    lh["key"] = "value"
    
    lh.store!
    
    pr1 = Splash::Lazy::FetchPromise.new(LazyTestHash1,lh._id,'key')
    demand(pr1).should == "value"
    
    pr2 = Splash::Lazy::FetchPromise.new(LazyTestHash1,lh._id,'na_key')
    demand(pr2).should_not be_available
    
    pr3 = Splash::Lazy::FetchPromise.new(LazyTestHash1,BSON::ObjectId('4c3759724c9ff84bf6000003'),'key')
    demand(pr3).should_not be_available
    
  end
  
  it "should fetch a given key" do
    
    class LazyTestHash2 < Hash
      
      include Splash::HasCollection
      
      def _id
        self["_id"]
      end
      
      def _id=(value)
        self["_id"]=value
      end
      
    end
    
    lh = LazyTestHash2.new
    
    lh["key"] = "value"
    
    lh.store!
    
    pr1 = {}
    pr1.extend(Splash::Lazy::Hash::Exclusive)
    pr1.initialize_laziness(LazyTestHash2,lh._id,'')
    pr1.lazify('key')
    pr1.lazify('nakey')
    pr1['key'].should == "value"
    pr1['nakey'].should_not be_given
    
  end
  
  it "should support lazy loading" do
    
    class LazyTestDocument1
      
      include Splash::Document
      
    end
    
    h1 = LazyTestDocument1.new("x"=>1,"y"=>1).store!
    h2 = LazyTestDocument1.new("x"=>2,"y"=>4).store!
    h3 = LazyTestDocument1.new("x"=>3,"y"=>9).store!
    h4 = LazyTestDocument1.new("x"=>4,"y"=>16).store!
    
    q = LazyTestDocument1.lazy('y')
    
    q.each do |h|
      h.y.should == h.x**2
    end
  end
  
  it "should support lazy on deeper nested fields" do
    
    class LazyTestDocument2
      
      include Splash::Document
      
      lazy!('child.y')
      
    end
    
    h1 = LazyTestDocument2.new("child"=>{"x"=>1,"y"=>1}).store!
    h2 = LazyTestDocument2.new("child"=>{"x"=>2,"y"=>4}).store!
    h3 = LazyTestDocument2.new("child"=>{"x"=>3,"y"=>9}).store!
    h4 = LazyTestDocument2.new("child"=>{"x"=>4,"y"=>16}).store!
    
    LazyTestDocument2.each do |h|
      h.child["y"].should == h.child["x"]**2
    end
      
    LazyTestDocument2.eager('child.y').each do |h|
      h.child["y"].should == h.child["x"]**2
    end
    
  end
  
  
end