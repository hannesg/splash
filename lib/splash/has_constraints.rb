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
module Splash
  
  module HasConstraints
    
    def self.included(base)
      base.merged_inheritable_attr(:constraints)
    end
    
    def validate
      result = Splash::Constraint::Result.new
      self.class.each_constraints do |constraint|
        constraint.validate(self,result)
      end
      return result
    end
    
protected
    def raise_unless_valid
      result = self.validate
      if result.error?
        raise Constraint::Invalid.new(self,result)
      end
    end
    
  end
  
end