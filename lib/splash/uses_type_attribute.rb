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

require 'facets/kernel/constant'

module Splash
  module UsesTypeAttribute
    
    TypeAttribute = 'Type'.freeze
    
    def self.get_class_hierachie(klass)
      base=[]
      begin
        unless klass.anonymous?
          base << klass
        end
        #return base unless klass.instance_of? Class
        klass = klass.superclass
      end while ( klass < Splash::UsesTypeAttribute )
      return base
    end
    
    extend Combineable
    extend Cautious
    
    module ConditionSetter
      def inherited(child)
        super
        if child.respond_to?(:conditions!) and !child.anonymous? and !child.has_own_collection?
          child.conditions!("Type"=>child.to_s)
        end
      end
    end
    
    module ClassMethods
      def to_saveable(value)
        value = super(value) if defined? super
        return value if value.nil?
        value[TypeAttribute] = Splash::UsesTypeAttribute.get_class_hierachie(self).map &:to_s
        return value
      end
      
      def from_saveable(value)
        return value if value.nil?
        if value.key? TypeAttribute
          klass = Kernel.constant(value[TypeAttribute].first)
          if klass < self
            return klass.from_saveable(value)
          end
        end
        return super(value) if defined? super
        return value
      end
    end
    
    combined_with(HasCollection) do |base|
      if base.kind_of? Class
        if base.respond_to?(:conditions!) and !base.anonymous? and !base.has_own_collection?
          base.conditions!("Type"=>base.to_s)
        end
        base.extend(ConditionSetter)
      end
    end
    
  end
end
