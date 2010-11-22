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
  
  def included(base=nil,&block)
    if base
      self.included_modules.each do |mod|
        begin
          mod.included(base)
        rescue NoMethodError
        end
      end
      #if base.kind_of? Class
        if self.const_defined?('ClassMethods')
          base.extend(self.const_get('ClassMethods'))
        end
      #else
        
      #end
      if @concerned_block
        base.instance_eval( &@concerned_block )
      end
      super
    elsif block_given?
      @concerned_block = block
    end
  end
  
end