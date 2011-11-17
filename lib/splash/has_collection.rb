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
    
    extend Cautious
    
    when_included do |base|
      base.merged_inheritable_attr :safe_on_keys
      base.instance_variable_set('@is_collection_base',true)
    end
    
    def store!
      if self._id.given?
        self.update!
      else
        self.insert!
      end
      return self
    end
    
    def update!
      self.class.update!(self)
      return self
    end
    
    def insert!
      self._id=self.class.insert!(self)
      return self
    end
    
    def _dbref
      self.demand_id!
      return BSON::DBRef.new(self.class.collection.name,self._id)
    end
    
    def remove!
      return self.class.collection.remove('_id'=>self._id)
    end
    
    def demand_id!
      unless self._id.given?
        self._id = self.class.collection.pk_factory.create_pk(self.class.eigenpersister.to_saveable(self))[:_id]
      end
      return self._id
    end
    
    def ==(other)
      return ( other.kind_of?(Splash::HasCollection) and !(self.class < other.class).nil? and self._id == other._id )
    end
    
    def hash
      demand_id!
      #TODO: not a good idea!
      # => should be more on collection base
      ( self.class.hash << 32 ) + self._id.hash
    end
    
    # This method will create a clone of the current object,
    # which will be saved as new document.
    def as_new
      c = self.dup
      c._id = nil
      return c
    end
    
    alias eql? ==
    
    module ClassMethods
      
      attr_accessor :safe
      
      def ensure_id!(hash)
        self.collection.pk_factory.create_pk(hash)
        if hash[:_id]
          hash['_id'] = hash.delete(:_id)
        end
        return hash['_id']
      end
    
      def <<(obj)
        super(obj) if defined? super
        obj.store!
      end
      
      def store!(object)
        so = eigenpersister.to_saveable(object)
        return self.collection.save( so, options_for(so) );
      end
      
      def insert!(object)
        so = eigenpersister.to_saveable(object)
        return self.collection.insert( so, options_for(so) );
      end
      
      def update!(object)
        so = eigenpersister.to_saveable(object)
        return update_incremental!( so['_id'], so )
      end
      
      def update_incremental!(id,data)
        return self.collection.update({:_id=>id}, data, options_for(data))
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
        return super if defined? super
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
        if self.respond_to?(:_collection) and self.method(:_colletion).owner == self.extension
          return true
        end
        k = self.superclass
        while( k.anonymous? )
          k = k.superclass
        end
        if k < Splash::HasCollection
          return false
        end
        return true
      end
      
      SAFE_OPTIONS = {:safe => true}.freeze
      DEFAULT_OPTIONS = {}.freeze
      
      def options_for(doc)
        
        if safe
          return SAFE_OPTIONS
        else
          self.each_safe_on_keys do |k|
            if doc.key? k
              return SAFE_OPTIONS
            end
            if doc.key?('$set') and doc['$set'].key? k
              return SAFE_OPTIONS
            end
            if doc.key?('$unset') and doc['$unset'].key? k
              return SAFE_OPTIONS
            end
          end
        end
        return DEFAULT_OPTIONS
      end
      
    end
    
  end
  
end
