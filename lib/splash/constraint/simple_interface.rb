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
    
    extend Cautious
    
    include Splash::Annotated
    
    module ClassMethods
      
      def validate(*args,&block)
        if block_given?
          self.constraints << Constraint::Simple.new(*args,&block)
        else
          args.each do |name|
            self.constraints << Constraint::Callback.new(name)
          end
        end
      end
      
      def validate_is_not(what, *args)
        if args.none?
          annote do |meth|
            validate_is_not(what, meth.to_s)
          end
          return
        end
        args.each do |name|
          self.constraints << Constraint::Simple.new(name){|object,result|
            if object.send("#{what}?")
              result.errors << result._(:may_not_be,what.to_sym)
            end
          }
        end
      end
      
      def validate_is(what, *args)
        if args.none?
          annote do |meth|
            validate_is(what, meth.to_s)
          end
          return
        end
        args.each do |name|
          self.constraints << Constraint::Simple.new(name){|object,result|
            if object.send("#{what}?")
              result.errors << result._(:must_be,what.to_sym)
            end
          }
        end
      end
      
      def validate_not_nil(*args)
        if args.none?
          annote do |meth|
            validate_not_nil(meth.to_s)
          end
          return
        end
        args.each do |name|
          self.constraints << Constraint::Simple.new(name){|object,result|
            if object.given?
              result.errors << result._.may_not_be_nil
            end
          }
        end
      end
    
    end
  end
end
