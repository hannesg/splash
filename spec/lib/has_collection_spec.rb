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
        self["_id"]
      end
      
      def _id=(value)
        self["_id"]=value
      end
      
    end
    
    h = HashWithCollection['xy',123]
    
    h.store!
    
  end
  
  it "should support something other than ObjectId as _id" do
    
    
  end
  
end