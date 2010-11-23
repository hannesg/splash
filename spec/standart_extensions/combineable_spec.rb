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

describe Combineable do
  
  it "should work in a simple case" do
    module CombineableX
      
    end
    
    module CombineableY
      
      extend Combineable
      
      combined_with( CombineableX ) do |base|
        
        def base.answear
          42
        end
        
      end
      
    end
    
    class CombinedXY
      
      include CombineableX
      include CombineableY
      
    end
    
    class CombinedYX
      
      include CombineableY
      include CombineableX
      
    end
    
    class CombinedYParent
      
      include CombineableY
      
    end
    
    class CombinedYChild < CombinedYParent
      
      include CombineableX
      
    end
    
    class CombinedYChild2 < CombinedYParent
      
      include CombineableX
      
    end
    
    class CombinedYChildChild < CombinedYChild
      
    end
    
    CombinedXY.should respond_to(:answear)
    CombinedXY.answear.should == 42
    
    CombinedYX.should respond_to(:answear)
    CombinedYX.answear.should == 42
    
    CombinedYChild.should respond_to(:answear)
    CombinedYChild.answear.should == 42
    
    CombinedYChild2.should respond_to(:answear)
    CombinedYChild2.answear.should == 42
    
    CombinedYChildChild.should respond_to(:answear)
    CombinedYChildChild.answear.should == 42
    
  end
  
end