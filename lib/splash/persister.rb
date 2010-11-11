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
  module Persister
  
    RAW_TYPES=[String,NilClass,Numeric,Float,Regexp,Fixnum,FalseClass,TrueClass,BSON::ObjectId,Time,BSON::Code,BSON::DBRef,BSON::Binary,Symbol]
    
    def self.raw?(value)
      return true if RAW_TYPES.any? do |type| value.class == type end
      if value.kind_of?(Hash)
        value.each do |key,val|
          return false unless self.raw?(key)
          return false unless self.raw?(val)
        end
        return true
      elsif value.kind_of?(Array)
        value.each do |sub|
          return false unless self.raw?(sub)
        end
        return true
      end
      return false
    end

  end

end
