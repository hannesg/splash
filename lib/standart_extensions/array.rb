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
class Array
  
  def deep_clone
    c = self.clone
    c.map!{|v|
      v.deep_clone
    }
    return c
  end
  
  def map_lazy(&block)
    result = Splash::Lazy::Array.new(self)
    result.lazy_mapper = block
    return result
  end
  
  def present_indices
    0..(size-1)
  end
  
end