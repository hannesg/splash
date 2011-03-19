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
module Cautious
  
  module SlightlyCautious
    
    def included(base)
      self.included_modules.reverse_each do |mod|
        #next unless mod.kind_of? SlightlyCautious
        begin
          mod.included(base)
        rescue NoMethodError
        end
      end
      super
      if base.method(:included).owner == Module
        base.extend(SlightlyCautious)
      end
    end
    
    def inherited(base)
      if base.method(:inherited).owner == Class
        base.extend(SlightlyCautious)
      end
      super
    end
    
    def extended(base)
      if !base.respond_to? :extended
        if self.const_defined?('ClassMethods')
          base.extend(self::ClassMethods)
        end
        return 
      end
      if base.method(:extended).owner == Module
        base.extend(SlightlyCautious)
      end
      super
    end
    
  end
  
  include SlightlyCautious
  
  def included(base)
    if self.const_defined?('ClassMethods')
      base.extend(self::ClassMethods)
    end
    if instance_variable_defined? :@cautious_included_block and @cautious_included_block
      @cautious_included_block.call(base)
    end
    super
  end
  
  def inherited(base)
    super
    if @cautious_inherited_block
      @cautious_inherited_block.call(base)
    end
  end
  
  def extended(base)
    super
    if @cautious_extended_block
      @cautious_extended_block.call(base)
    end
  end
  
  def self.extended(base)
    base.extend(SlightlyCautious)
  end
  
  def when_included(&block)
    @cautious_included_block = block
  end
  
  def when_inherited(&block)
    @cautious_inherited_block = block
  end
  
  def when_extended(&block)
    @cautious_extended_block = block
  end
  
end