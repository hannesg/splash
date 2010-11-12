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
    
    def validate(object,result)
      sub_object = DotNotation.get(object,@key)
      if sub_object.kind_of? Array
        sub_object.each_with_index do |obj,i|
          if obj.respond_to? :validate
            sub_result = obj.validate
            if sub_result.error?
              result.errors[@key] << sub_result
            end
          end
        end
      else
        if sub_object.respond_to? :validate
          sub_result = sub_object.validate
          if sub_result.error?
            result.errors[@key] << sub_result
          end
        end
      end
    end
    
protected
    def distribute(errors,name,suberrors)
      suberrors.each do |k,v|
        errors[ (name.to_s + '.' + k.to_s) ] += v
      end
    end
  end
end