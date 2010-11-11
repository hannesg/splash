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

describe Splash::Embed do
  
  it "should be saveable as document attribute" do
    
    class ICQ
      
      include Splash::Embed
      
      attribute "uin"
      
    end
    
    
    class Customer
      
      include Splash::Document
      
      attribute 'icq', ICQ
      
      attribute('friends', Array.of(ICQ)) do
        
        default &:new
        
      end
      
    end
    c = Customer.new( 'icq' => ICQ.new('uin'=>1337) )
    
    c.friends << ICQ.new('uin' => 666)
    c.friends << ICQ.new('uin' => 888)
    
    c.store!
    
    
  end
  
end