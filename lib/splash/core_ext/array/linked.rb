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
class Array::Linked < Array
  
  attr_accessor :successor
  
  def each(&block)
    super
    successor.each(&block) if successor
  end
  
  def include?(value)
    super or (successor and successor.include? value)
  end
  
  def [](key)
    k = key - self.size
    if successor and k > 0
      return successor[k]
    end
    super
  end
  
  def push(value)
    if successor
      successor.push(value)
      return self
    end
    super
  end
  
  def pop
    if successor
      return successor.pop
    end
    super
  end
  
end