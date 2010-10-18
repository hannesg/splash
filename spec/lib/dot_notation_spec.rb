# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::DotNotation do
  
  describe "get" do
    it "should work in a simple case" do
      
      x = {
        
        'a'=> {
          
          'b' => {
            
            'c' => 'd'
          }
          
        }
        
      }
      
      Splash::DotNotation.get(x,'a.b.c').should == 'd'
      
    end
    
    it "should work with arrays in a simple case" do
      
      x = {
        
        'a'=> {
          
          'b' => [
            {
              'c' => 'd'
            },
            {
              'c' => 'D'
            }
          ]
        }
        
      }
      
      Splash::DotNotation.get(x,'a.b.c').should == ['d','D']
      
    end
  end
  
  describe "set" do
    it "should work in a simple case" do
      
      x = {
        
        'a'=> {
          
          'b' => {
            
            'c' => 'd'
          }
          
        }
        
      }
      
      Splash::DotNotation.set(x,'a.b.x','y')
      
      x['a']['b'].should == {'c'=>'d','x'=>'y'}
      
    end
    
    it "should work with arrays in a simple case" do
      
      x = {
        
        'a'=> {
          
          'b' => [
            {
              'c' => 'd'
            },
            {
              'c' => 'D'
            }
          ]
          
        }
        
      }
      
      Splash::DotNotation.set(x,'a.b.x','y')
      
      x['a']['b'].should == [
            {
              'c' => 'd',
              'x'=>'y'
            },
            {
              'c' => 'D',
              'x'=>'y'
            }
          ]
      
    end
  end
  
end