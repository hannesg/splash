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
    
    it "should work with arrays and indices" do
      
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
      
      Splash::DotNotation.set(x,'a.b.1.x','y')
      
      x['a']['b'].should == [
            {
              'c' => 'd'
            },
            {
              'c' => 'D',
              'x'=>'y'
            }
          ]
      
    end
  end
  
  describe "enumeration" do
    
    it "should work in an easy case" do
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
      result = []
      Splash::DotNotation::Enumerator.new(x,'a.b.c').each do |path,obj|
        if obj == 'd'
          path.should == ['a','b',0,'c']
        elsif obj == 'D'
          path.should == ['a','b',1,'c']
        else
          raise "Unexpected object: #{obj.inspect}"
        end
        
      end
      
    end
    
  end
  
end