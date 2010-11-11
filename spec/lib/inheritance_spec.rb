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

describe "inheritance" do
  
  it "should generate normal methods" do
    
    class A
      
      merged_inheritable_attr :a
      merged_inheritable_attr :b,"b"
      
    end
    
    A.respond_to?(:a).should be_true
    A.respond_to?(:b).should be_true
    
    A.b.should == "b"
    
    A.all_b.should == "b"
    
    
  end
  
  it "should generate inheritable methods" do
    
    class A
      
      merged_inheritable_attr :a
      merged_inheritable_attr :b,"b" do |a,b|
        a + b
      end
      
    end
    
    class B < A
      
    end
    
    class C < B
      merged_inheritable_attr :c
    end
    
    A.a << 1
    
    B.respond_to?(:a).should be_true
    B.respond_to?(:b).should be_true
    
    B.b = "c"
    
    B.a << 2
    
    B.all_b.should == "cb"
    
    C.all_b.should == "bcb"
    
    C.a << 3
    
    A.a.should have(1).item
    A.all_a.should have(1).item
    
    B.a.should have(1).item
    B.all_a.should have(2).items
    
    C.a.should have(1).item
    C.all_a.should have(3).items
    
  end
  
end
