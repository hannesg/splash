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

humanized_gem = Gem.loaded_specs['humanized']
if humanized_gem
  require "splash/extras/humanized.rb"
end

describe "humanized" do
  
  it "should work" do
    
    pending "humanized not loaded" unless humanized_gem
    
    De = Humanized::Humanizer.new
    
    class User
      
      include Splash::HasAttributes
      
      De[_] = {
        :genus => :male,
        :singular => {
          :nominativ => 'Benutzer',
          :genitiv => 'Benutzers'
        }
      }
      
      attribute('name') do
        
        De[_] = {
          :genus => :male,
          :singular => {
            :nominativ => 'Name',
            :genitiv => 'Namens'
          }
        }
        
      end
      
    end
    
    
    De.get(User,:genus).should == :male
    De.get(User.attribute('name'),:singular,:genitiv).should == 'Namens'
    
  end
  
end