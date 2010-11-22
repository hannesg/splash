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
  
  module HasCollection
    
    extend Concerned
    
    included do
      instance_variable_set('@is_collection_base',true)
    end
    
    def store!
      self._id=self.class.store!(self)
      return self
    end
    
    def remove!
      return self.class.collection.remove('_id'=>self._id)
    end
    
    def initialize(*args)
      self._id = self.class.collection.pk_factory.new
      super
    end
    
    def ==(other)
      return ( other.kind_of?(Splash::HasCollection) and !(self.class < other.class).nil? and self._id == other._id )
    end
    
    def hash
      ( self.class.hash << 32 ) + self._id.hash
    end
    
    alias eql? ==
    
    module ClassMethods
      
      def <<(obj)
        obj.store!
      end
      
      def create_index(*args)
        self.collection.create_index(*args)
      end
      
      def drop_index(*args)
        self.collection.drop_index(*args)
      end
      
      def store!(object)
        return self.collection.save(
          eigenpersister.to_saveable(object)
        );
      end
      
      def namespace(*args)
        if args.any?
          self.namespace=args.first
        end
        return (@namespace || Splash::Namespace.default)
      end
      
      def namespace=(arg)
        if arg.kind_of? Splash::Namespace
          @namespace = arg
          self.collection= nil
        else
          @namespace = Splash::Namespace::NAMESPACES[arg]
          self.collection = nil
        end
      end
      
      def eigenpersister
        return self
      end
      
      def collection(*args)
        if args.any?
          self.collection= args.first
        end
        if self.respond_to? :_collection
          return self._collection
        else
          return namespace.collection_for(self)
        end
      end
      
      def collection=(arg)
        if arg
          (class << self; method(:define_method); end).call(:_collection){
            arg
          }
        elsif( self.respond_to? :_collection )
          (class << self; undef_method(:_collection); end)
        end
      end
      
      def has_own_collection?
        if self.respond_to?(:_collection) and self.method(:_colletion).owner == self.eigenclass
          return true
        end
        k = self.superclass
        while( !k.named? )
          k = k.superclass
        end
        if k < Splash::HasCollection
          return false
        end
        return true
      end
      
    end
    
  end
  
end