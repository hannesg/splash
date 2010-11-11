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
module Splash::DotNotation
  
  def get(path)
    Splash::DotNotation.get(self,path)
  end
  
  
  def set(path,value)
    Splash::DotNotation.set(self,path,value)
  end
  
  def self.get(object,path)
    return object if path.nil?
    rest = path
    loop do
      if object.kind_of? Array
        return object.map do |sub|
          Splash::DotNotation.get(sub,rest)
        end
      end
      first,rest = rest.split('.',2)
      if object.kind_of? Hash
        object = object[first]
      else
        object = object.send(first)
      end
      unless rest
        return object
      end
    end
  end
  
  def self.set(object,path,value)
    rest = path
    loop do
      if object.kind_of? Array
        return object.map do |sub|
          Splash::DotNotation.set(sub,rest,value)
        end
      end
      first,rest = rest.split('.',2)
      if rest
        if object.kind_of? Hash
          object = object[first]
        else
          object = object.send(first)
        end
      else
        if object.kind_of? Hash
          return object[first] = value
        else
          return object.send(first + '=',value)
        end
      end
    end
  end
  
end