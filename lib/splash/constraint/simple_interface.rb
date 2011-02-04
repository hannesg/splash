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
  module Constraint::SimpleInterface
    
    def validate(*args,&block)
      if block_given?
        self.constraints << Constraint::Simple.new(*args,&block)
      else
        args.each do |name|
          self.constraints << Constraint::Callback.new(name)
        end
      end
    end
    
    def validate_not_nil(name)
      self.constraints << Constraint::Simple.new{|object,result|
        if Splash::DotNotation.get(object,name).nil?
          result[name] << "#{name} may not be nil"
        end
      }
    end
    define_annotation :validate_not_nil
    
    
  end
end