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
module Splash::Embed
  
  class Persister
    def to_saveable(value)
      return value if value.nil?
      return Splash::Saveable.wrap(value)
    end
    
    def from_saveable(value)
      return value if value.nil?
      return Splash::Saveable.load(value,@base_class)
    end
    
    def initialize(klass)
      @base_class = klass
    end
    
  end
  
  include Splash::HasAttributes
  include Splash::Saveable
  #include Splash::Validates
  
  class << self
    def included(base)
      base.extend(ClassMethods)
      included_modules.each do |mod|
        begin
          mod.included(base)
        rescue NoMethodError
        end
      end
    end
    
    def define(&block)
      c=Class.new()
      mod = self
      c.instance_eval do
        include mod
      end
      c.class_eval(&block)
      c
    end
    
    def persister
      Splash::Embed::Persister.new(self.define{})
    end
  end
  
  module ClassMethods
    def persister
      Splash::Embed::Persister.new(self)
    end
  end
  
end
