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
module Splash::Annotated
  
  class << self
    def included(base)
      base.extend(ClassMethods)
    end
  end
  
  
  module ClassMethods
  
    def method_added(meth)
      apply_annotations(meth)
      super
    end
    
    def apply_annotations(meth)
      return if @annotations.nil?
      a = @annotations
      @annotations=[]
      a.each do |(fn,args,block)|
        args.unshift(meth)
        self.send(fn,*args,&block)
      end
      return nil
    end
    
    def included(base)
      included_modules.each do |mod|
        mod.included(base)
      end
    end
    
  end
end
