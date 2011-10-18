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

describe Splash::ActsAsScope do
  
  describe "nesting" do
    
    it "should support a trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
        extend_scoped! do
          def jpeg
            conditions('type'=>'jpeg')
          end
          
          def wider_than(wd)
            conditions('width'=>{'$gt'=>wd})
          end
          
          def heigher_than(hd)
            conditions('height'=>{'$gt'=>wd})
          end
        end
        
      end
      
      Picture.new('type'=>'jpeg','width'=>200,'height'=>200).store!
      Picture.new('type'=>'gif','width'=>200,'height'=>200).store!
      Picture.new('type'=>'jpeg','width'=>400,'height'=>200).store!
      Picture.new('type'=>'jpeg','width'=>100,'height'=>200).store!
      Picture.new('type'=>'png','width'=>200,'height'=>100).store!
      Picture.new('type'=>'png','width'=>150,'height'=>20).store!
      
      Picture.jpeg.wider_than(300).count.should == 1
      
    end
    
  end
  
  
  describe "write back" do
    
    it "should support a trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
      end
      
      jpegs = Picture.conditions('type'=>'jpeg').writeback('type'=>'jpeg')
      
      p = Picture.new
      
      jpegs << p
      
      jpegs.to_a.should include p
      
    end
    
    it "should support another trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
      end
      
      jpegs = Picture.where('type'=>'jpeg')
      
      p = Picture.new
      
      jpegs << p
      
      jpegs.to_a.should include p
      
    end
    
    it "should support the third trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
      end
      
      jpegs = Picture.where('type'=>'jpeg')
      
      p = jpegs.create
      
      jpegs.to_a.should include p
      
    end
    
  end
  
  describe "arraylike access" do
    
    it "should support ranges" do
      class Foo
        include Splash::Document
        
        attribute "i"
        
      end
      i = 1
      20.times do
        f = Foo.new("i"=>i)
        f.store!
        i+=1
      end
      
      Foo[5..15].to_a.should have(10).items
      Foo[5..-1].to_a.should have(15).items
      Foo[5...15].to_a.should have(9).items
    end
    
    it "should support skip with offset" do
      class Foo
        include Splash::Document
      end
      i = 1
      20.times do
        f = Foo.new("i"=>i)
        f.store!
        i+=1
      end
      
      Foo[5,10].to_a.should have(10).items
      
    end
  end
  
  describe "code with scope" do
    
    it "should work in a trivial case" do
      
      # okay, could be solved easier, but it a test ...
      
      class Nerd
        
        include Splash::Document
        
        attribute 'age', Integer
        
      end
      
      Nerd.new('age'=>13).store!
      Nerd.new('age'=>16).store!
      Nerd.new('age'=>17).store!
      Nerd.new('age'=>21).store!
      
      a_16 = Nerd.conditions('$where'=>BSON::Code.new('this.age > threshold','threshold'=>16)).to_a
      
      a_16.should have(2).items
      
    end
    
    
  end
  
  describe "enumerability" do
  
    it "should be mapable" do
      
      class Nerd
        
        include Splash::Document
        
        attribute 'age', Integer
        
      end
      
      Nerd.new('age'=>13).store!
      Nerd.new('age'=>16).store!
      Nerd.new('age'=>17).store!
      Nerd.new('age'=>21).store!
      
      Nerd.collect(&:age).should == [13,16,17,21]
      
    end
    
    it "should be mapable (unchunked)" do
      class Nerd
        
        include Splash::Document
        
        attribute 'age', Integer
        
      end
      
      Nerd.new('age'=>13).store!
      Nerd.new('age'=>16).store!
      Nerd.new('age'=>17).store!
      Nerd.new('age'=>21).store!
      
      Nerd.each_unchunked.collect(&:age).should == [13,16,17,21]
      
      Nerd.each_unchunked{|id,obj| [id,obj.age] }
      
    end
  
  end
  
end
