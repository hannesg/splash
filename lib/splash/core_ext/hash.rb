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
  
  def deep_clone
    c = self.clone
    keys = c.keys
    keys.each do |k|
      c[ k.deep_clone ] = c.delete(k).deep_clone
    end
    return c
  end
  
end
