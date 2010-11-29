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
    
    pr1 = BSON::OrderedHash.new
    pr1.extend(Splash::Lazy::Hash::Exclusive)
    pr1.initialize_laziness(LazyTestHash2.collection,lh._id,'')
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
  
  it "should support lazy loading" do
    
    class LazyTestDocument2
      
      include Splash::Document
      
      fieldmode! :include
      eager! 'x', 'Type'
      
    end
    
    h1 = LazyTestDocument2.new("x"=>1,"y"=>1).store!
    h2 = LazyTestDocument2.new("x"=>2,"y"=>4).store!
    h3 = LazyTestDocument2.new("x"=>3,"y"=>9).store!
    h4 = LazyTestDocument2.new("x"=>4,"y"=>16).store!
    
    Splash::Namespace.count_requests{
      LazyTestDocument2.each do |h|
        h.y.should == h.x**2
      end
    }.should == 5
    
    Splash::Namespace.count_requests{
      LazyTestDocument2.eager('z').each do |h|
        h.z.should_not be_available
      end
    }.should == 1
  end
  
  it "should support lazy loading" do
    
    class LazyTestDocument3
      
      include Splash::Documentbase
      include Splash::HasAttributes
      include Splash::HasCollection
      
      fieldmode! :none
      
    end
    
    h1 = LazyTestDocument3.new("x"=>1,"y"=>1).store!
    h2 = LazyTestDocument3.new("x"=>2,"y"=>4).store!
    h3 = LazyTestDocument3.new("x"=>3,"y"=>9).store!
    h4 = LazyTestDocument3.new("x"=>4,"y"=>16).store!
    
    Splash::Namespace.count_requests{
      LazyTestDocument3.each do |h|
        h.y.should == h.x**2
      end
    }.should == 9
    
    Splash::Namespace.count_requests{
      LazyTestDocument3.eager('y').each do |h|
        h.y.should == h.x**2
      end
    }.should == 9
  end
  
  it "should support lazy on deeper nested fields" do
    
    class LazyTestDocument4
      
      include Splash::Document
      
      lazy!('child.y')
      
    end
    
    h1 = LazyTestDocument4.new("child"=>{"x"=>1,"y"=>1}).store!
    h2 = LazyTestDocument4.new("child"=>{"x"=>2,"y"=>4}).store!
    h3 = LazyTestDocument4.new("child"=>{"x"=>3,"y"=>9}).store!
    h4 = LazyTestDocument4.new("child"=>{"x"=>4,"y"=>16}).store!
    
    Splash::Namespace.count_requests{
    LazyTestDocument4.each do |h|
      h.child["y"].should == h.child["x"]**2
    end
    }.should == 5
    
    Splash::Namespace.count_requests{
    LazyTestDocument4.eager('child.y').each do |h|
      h.child["y"].should == h.child["x"]**2
    end
    }.should == 1
  end
  
  it "should be dupable" do
    
    col = Splash::Namespace.default.collection('lazy_test3')
    col.save({
      'first_name'=>'Mike',
      'last_name'=>'Sim',
      'interests'=>[{'name'=>'Basketball'},{'name'=>'Golf'}],
      'deeply'=>{'nested'=>{'thing'=>'lulz!'}}
    })
    
    doc = col.find_one(nil,{:fields=>{'last_name'=>0,'deeply.nested.thing'=>0}})
    doc2 = col.find_one(nil,{:fields=>{'first_name'=>1,'interests'=>1}})
  
    docc = nil
    Splash::Namespace.count_requests{
      docc = doc.deep_clone
    }.should == 0
    
    doc.lazy?('last_name').should be_true
    docc['last_name'].should == 'Sim'
    docc['deeply']['nested']['thing'].should == 'lulz!'
    docc['interests'] << {'name'=>'Programming'}
    doc['interests'].should have(2).items
    
    docc2 = nil
    Splash::Namespace.count_requests{
      docc2 = doc2.deep_clone
    }.should == 0
    docc2['last_name'].should == 'Sim'
    doc2['last_name'].should == 'Sim'
    docc2['deeply']['nested']['thing'].should == 'lulz!'
    docc2['interests'] << {'name'=>'Programming'}
    doc2['interests'].should have(2).items
    
  end
  
  
end