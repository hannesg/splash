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
  
  class Constraint::Valid < Constraint
    
    class Invalid < StandardError
    end
    
    def initialize(key)
      @key = key
    end
    
    def validates
      @key
    end
    
    def validate(object,result)
      DotNotation::Enumerator.new(object,@key).each do |path,sub|
        if sub.respond_to? :validate
          sub_result = sub.validate
          if sub_result.error?
            DotNotation.get(result,path) << sub_result
          end
        end
      end
    end
  end
end