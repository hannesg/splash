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

describe 'single table inheritance' do
  
  it "should work" do
    
    class STIBase
      
      include Splash::Document
      
      attribute 'name'
      
    end
    
    class STIChildOne < STIBase
      
    end
    
    class STIChildTwo < STIBase
      
    end
    
    class STIChildOneChild < STIChildOne
      
    end
    
    
    STIBase.new('name'=>'base1').store!
    STIBase.new('name'=>'base2').store!
    STIBase.new('name'=>'base3').store!
    
    STIChildOne.new('name'=>'child1_1').store!
    STIChildOne.new('name'=>'child1_2').store!
    STIChildOne.new('name'=>'child1_3').store!
    STIChildOne.new('name'=>'child1_4').store!
    STIChildOne.new('name'=>'child1_5').store!
    
    STIChildTwo.new('name'=>'child2_1').store!
    STIChildTwo.new('name'=>'child2_2').store!
    STIChildTwo.new('name'=>'child2_3').store!
    
    STIChildOneChild.new('name'=>'child1_1_1').store!
    
    STIBase.count.should == 12
    
    STIChildOne.count.should == 6
    
    STIChildTwo.count.should == 3
    
    STIChildOneChild.count.should == 1
    
  end
  
end
