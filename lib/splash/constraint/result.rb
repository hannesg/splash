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
  
  class Constraint::Result
    
    attr_reader :errors
    
    def initialize()
      self.errors = Hash.new do |hsh,key|
        hsh[key] = []
      end
    end
    
    def valid?
      errors.all?{|k,v| v.empty?}
    end
    
    def error?
      !valid?
    end
    
    def [](k)
      self.errors[k]
    end
    
    def []=(k,v)
      self.errors[k]=v
    end
    
    def kind_of?(x)
      if x == Hash
        return true
      end
      super
    end
    
    def to_s
      self.errors.each do |k,errors|
        errors.each do |error|
          m << "\t#{error.to_s}\n"
        end
      end
    end
    
  end
  
  
end