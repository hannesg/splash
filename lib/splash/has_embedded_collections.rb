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
  module HasEmbeddedCollections
    
    extend Cautious
    
    module ClassMethods
      
      def embedded_class(name)
        @embeds ||= {}
        return @embeds[name]
      end
      
      def embeds(name,options={})
        
        klass = options[:class] #|| self.collection.embed(name)
        
        #TODO: should this be inheritable?
        @embeds ||= {}
        
        @embeds[name]= klass
        
        if self.respond_to? :attribute
          self.attribute(name, EmbeddedCollection.of(klass)) do
            default :new
          end
        end

        meth = self.instance_method(name.to_sym)

        self.send(:define_method,name.to_sym) do
          thiz = self
          value = meth.bind(self).call() || []
          Class.new(klass) do
            collection thiz.class.collection.embed(name).slice(thiz._id,value)
            writeback! do |doc|
              doc._owner = thiz._dbref
            end
          end
        end
        self.send(:define_method,"#{name}=".to_sym) do |value|
          if value.kind_of? Array
            collection = self.send(name)
            collection.remove
            collection.<<(*value)
          end
        end
      end
    end
    
    
    
  end
end
