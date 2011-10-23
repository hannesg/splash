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

describe Splash::HasCollection do
  
  it "should support setting the collection" do
    
    class HasCollectionClass
      
      include Splash::HasCollection
      
    end
    
    c = HasCollectionClass.collection
    
    HasCollectionClass.collection = HasCollectionClass.namespace.collection('old_has')
    
    HasCollectionClass.collection.should_not == c
    
  end
  
  it "should be usable bare" do
    
    class HashWithCollection < Hash
      
      include Splash::HasCollection
      
      def _id
        self[:_id] || self["_id"]
      end
      
      def _id=(value)
        self.delete(:_id)
        self["_id"]=value
      end
      
    end
    
    h = HashWithCollection['xy',123]
    
    h.store!
    
  end
  
  it "should support something other than ObjectId as _id" do
    
    
  end
  
  describe "as_new" do
  
    it "should work" do
    
      h = HashWithCollection['yx',1337]
      
      h.store!
      
      HashWithCollection.collection.count.should == 1
      
      f = h.as_new
      
      f.store!
      
      HashWithCollection.collection.count.should == 2
    
    end
    
    it "should work with an embedded collection" do
    
      class HasCollectionWithEmbeds < Hash
      
      
        include Splash::HasCollection
        include Splash::HasEmbeddedCollections
        
        class Comment
        
          include Splash::Document
        
          collection HasCollectionWithEmbeds.collection.embed('comments')
        
        end
        
        def _id
          self[:_id] || self["_id"]
        end
        
        def _id=(value)
          self.delete(:_id)
          self["_id"]=value
        end
        
        def comments
          self["comments"]
        end
        
        embeds 'comments', :class => Comment
      
      end
    
      hc = HasCollectionWithEmbeds.new
      hc.store!
      
      com = hc.comments.new.store!
      
      HasCollectionWithEmbeds::Comment.count.should == 1
    
      com2 = com.as_new
      
      com2.store!
      
      HasCollectionWithEmbeds::Comment.count.should == 2
    
      com3 = HasCollectionWithEmbeds::Comment.first.as_new
      
      com3.store!
      
      HasCollectionWithEmbeds::Comment.count.should == 3
      
      # looks ugly, but has_collection does not specify retrival
      hc = HasCollectionWithEmbeds.new.update(HasCollectionWithEmbeds.collection.find_one)
      
      hc.comments.count.should == 3
    
    end
  
  end
end
