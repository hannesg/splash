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
module Concerned
  
  module SlightlyConcerned
    
    def included(base)
      self.included_modules.reverse_each do |mod|
        #next unless mod.kind_of? SlightlyConcerned
        begin
          mod.included(base)
        rescue NoMethodError
        end
      end
      super
      if base.method(:included).owner == Module
        base.extend(SlightlyConcerned)
      end
    end
    
    def inherited(base)
      if base.method(:inherited).owner == Class
        base.extend(SlightlyConcerned)
      end
      super
    end
    
    def extended(base)
      if base.method(:extended).owner == Module
        base.extend(SlightlyConcerned)
      end
      super
    end
    
  end
  
  include SlightlyConcerned
  
  def included(base)
    if self.const_defined?('ClassMethods')
      cm = self.const_get('ClassMethods')
      base.extend(self.const_get('ClassMethods'))
    end
    if instance_variable_defined? :@concerned_included_block and @concerned_included_block
      @concerned_included_block.call(base)
    end
    super
  end
  
  def inherited(base)
    super
    if @concerned_inherited_block
      @concerned_inherited_block.call(base)
    end
  end
  
  def extended(base)
    super
    if @concerned_extended_block
      @concerned_extended_block.call(base)
    end
  end
  
  def self.extended(base)
    base.extend(SlightlyConcerned)
  end
  
  def when_included(&block)
    @concerned_included_block = block
  end
  
  def when_inherited(&block)
    @concerned_inherited_block = block
  end
  
  def when_extended(&block)
    @concerned_extended_block = block
  end
  
end