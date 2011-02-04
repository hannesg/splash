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
  
  class Constraint::Simple < Constraint
    
    def initialize(path='',&block)
      @path = path
      @block = block
    end
    
    def validate(object,result)
      if @block.arity == 2
        DotNotation::Enumerator.new(object,@path).each do |path,sub|
          @block.call(sub,DotNotation.get(result,path))
        end
      else
        
        DotNotation::Enumerator.new(object,@path).each do |path,sub|
          g = DotNotation.get(result,path)
          g.instance_exec(sub, &@block)
        end
      end
    end
    
  end
  
end