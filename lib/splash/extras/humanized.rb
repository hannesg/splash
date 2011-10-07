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
require "humanized.rb"
class Splash::Attribute
  
  def _(*args,&block)
    if @type != Object
      ( @class._(:attribute, @name.to_sym) | @type._ )._(*args, &block)
    else
      @class._(:attribute, @name.to_sym)._(*args, &block)
    end
  end
  
end

class Splash::Scope
  
  def _(*args,&block)
    scope_root._(*args, &block)
  end
  
end
