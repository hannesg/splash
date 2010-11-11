# -*- encoding : utf-8 -*-
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
