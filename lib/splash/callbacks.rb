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
module Splash::Callbacks
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  protected
  def run_callbacks(name,*args)
    regex = Regexp.new("^#{Regexp.escape name.to_s}_")
    self.methods.each do |meth|
      if meth.to_s =~ regex
        self.send(meth,*args)
      end
    end
  end
  
  def with_callbacks(name,*args)
    run_callbacks('before_' + name.to_s,*args)
    result = yield
    run_callbacks('after_' + name.to_s,*args)
    return result
  end
  
  module ClassMethods
    
    def with_callbacks(*args)
      args.each do |fn|
        alias_method(fn.to_s + '_without_callbacks',fn)
        self.class_eval <<RB, __FILE__, __LINE__
def #{fn}(*args)
  run_callbacks('before_#{fn}')
  result = super
  run_callbacks('after_#{fn}')
  return result
end
RB
      end
    end
    
    define_annotation :with_callbacks
    
  end
end
