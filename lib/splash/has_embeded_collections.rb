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
  module HasEmbededCollections
    
    extend Concerned
    
    module ClassMethods
      
      def embeds(name,options={})
        klass = options[:class] #|| self.collection.embed(name)
        self.send(:define_method,name.to_sym) do
          thiz = self
          value = super || []
          Class.new(klass) do
            collection thiz.class.collection.embed(name).slice(thiz._id,value)
            writeback! do |doc|
              doc._owner = thiz._dbref
            end
          end
        end
      end
    end
    
    
    
  end
end