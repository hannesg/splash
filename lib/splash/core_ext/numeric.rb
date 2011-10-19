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
class Numeric
  
  def self.to_saveable(x)
  
    begin
      if self.respond_to? :coerce
        x = self.coerce(x)
      end
    rescue ArgumentError
    end
    
    return x if x.kind_of?(Fixnum) or x.kind_of?(Float)
    
    begin
      return Float(x)
    rescue ArgumentError
      return Integer(x) rescue 0
    end
    
  end
  
  def self.from_saveable(x)
  
    begin
      if self.respond_to? :coerce
        return self.coerce(x)
      end
    rescue ArgumentError
    end
  
    return Float(x)
  end
  
end
