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
module Combineable
  
  Combination = Struct.new(:modules,:block)
  
  def combined_with(*modules,&block)
    @module_combinations ||= []
    @module_combinations << Combination.new(modules,block)
  end
  
  def included(base,*)
    super
    self.__combined(base)
  end

protected
  def __combined(base)
    if instance_variable_defined?(:@module_combinations)
      given = base.included_modules
      @module_combinations.each do |combination|
        # a bit expensive
        if combination.modules.all?{|mod| base <= mod }#{|mod| given.any?{|mod2| mod2 <= mod } }
          # Hit!
          combination.block.call(base)
        else
          __delay_combination(base,combination)
        end
      end
    end
  end
  
  def __delay_combination(base,combo)
    if !base.kind_of? IncludeInvader
      base.extend(IncludeInvader)
    end
    base.wait_on(combo)
  end
  
  module IncludeInvader
    
    def include(mod)
      super
      __recheck_combos(self)
    end
    
    def wait_on(combination)
      @module_combinations ||= []
      @module_combinations << combination
    end
    
protected
    def __recheck_combos(base)
      if self.kind_of? Class
        self.superclass.__recheck_combos(base) if self.superclass.respond_to? :__recheck_combos
      end
      if instance_variable_defined?(:@module_combinations)
        given = base.included_modules
        @module_combinations.each do |combination|
          # a bit expensive
          if combination.modules.all?{|mod| base <= mod } #{|mod| given.any?{|mod2| mod2 <= mod } }
            # Hit!
            combination.block.call(base)
            @module_combinations.delete(combination) if self == base
          end
        end
      end
    end
    
  end
  
end