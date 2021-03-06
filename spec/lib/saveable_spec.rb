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

describe 'saveable' do
  
  it "should implement a meaningful equal operator" do
    
    class Xy
      
      include Splash::Document
      
    end
    
    original = Xy.new('xkcd'=>'rocks!')
    
    original.store!
    
    Xy.to_a.first.should == original
    
  end
  
  it "should support documents as hash keys" do
    
    class Xyz
      
      include Splash::Document
      
      attribute "i"
      
    end
    
    hash = {}
    
    (1..10).each do |i|
      
      hash[Xyz.new("i"=>i).store!] = i
      
    end
    
    Xyz.each do |xyz|
      
      hash[xyz].should == xyz.i
      
    end
    
  end
  
end
