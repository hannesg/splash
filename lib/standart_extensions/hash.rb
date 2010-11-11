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
require File.join File.dirname(__FILE__), "object"
require File.join File.dirname(__FILE__), "module"
class Hash
  
  DEEP_MERGER=proc{|key,value,value2|
    if( value.kind_of?(Hash) && value2.kind_of?(Hash) )
      value.merge(value2,&DEEP_MERGER)
    else
      value2
    end
  }
  
  def deep_merge(k)
    return self if k.nil?
    merge(k,&DEEP_MERGER)
  end
  
  def deep_merge!(k)
    return self if k.nil?
    merge!(k,&DEEP_MERGER)
  end
  
  def only(keys)
    self.reject{|key,val| !keys.include? key}
  end
  
  def except(keys)
    self.reject{|key,val| keys.include? key}
  end
  
  def hashmap
    self.inject({}) do |newhash, (k,v)|
      newhash[k] = yield(k, v)
      newhash
    end
  end
  
  def +(hsh)
    self.merge(hsh)
  end
  
end
