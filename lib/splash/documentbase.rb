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
module Splash::Documentbase
  
  class Persister
  
    # NOTE: the : in a collection name is a custom extension
    DBREF = /^ns: ([A-Za-z0-9_\.:]+), id: ([0-9a-f]{24})$/.freeze
    OBJECTID = /[0-9a-f]{24}$/.freeze
  
    def to_saveable(value)
      return nil if value.nil?
      return BSON::DBRef.new( value.class.collection.name , value._id )
    end
    
    def from_saveable(value)
      return nil if value.nil?
      
      if value.kind_of? BSON::DBRef
        found_class = @namespace.class_for(value.namespace)
        unless found_class <= @class
          warn "Trying to fetch an object of type #{found_class} from #{@class}."
          return nil
        end
        return found_class.conditions('_id'=>value.object_id).first
      elsif value.kind_of? BSON::ObjectId
        return @class.conditions('_id' => value).first
      elsif value.kind_of? Hash and value['object_id'].kind_of? String and value['namespace'].kind_of? String
        found_class = @namespace.class_for(value['object_id'])
        unless found_class <= @class
          warn "Trying to fetch an object of type #{found_class} from #{@class}."
          return nil
        end
        return found_class.conditions('_id'=> BSON::ObjectId.from_string(value['namespace']) ).first
      elsif value.kind_of? String
        if DBREF =~ value
          found_class = @namespace.class_for($1)
          unless found_class <= @class
            warn "Trying to fetch an object of type #{found_class} from #{@class}."
            return nil
          end
          return found_class.conditions('_id'=> BSON::ObjectId.from_string($2) ).first
        elsif OBJECTID =~ value
          return @class.conditions('_id' => BSON::ObjectId.from_string(value) ).first
        end
      end
      raise "No idea how to fetch #{value}."
    end
    
    def initialize(ns,klass = Object )
      @namespace, @class = ns, klass
    end
  end
  
  class ByIdPersister < Persister
    
    def to_saveable(value)
      return nil if value.nil?
      return value._id
    end
    
  end
  
  class ByIdStringPersister < Persister
    
    def to_saveable(value)
      return nil if value.nil?
      return value._id.to_s
    end
    
  end
  
  
  extend Combineable
  
  extend Cautious
  
  combined_with( Splash::HasConstraints, Splash::Callbacks, Splash::HasCollection ) do |base|
    
    base.with_callbacks :store!, :insert!, :update!
    base.class_eval do
      def before_store_validate
        self.raise_unless_valid
      end
    end
    
  end
  
  when_included do |base|
    if base.kind_of? Class
      base.extend Splash::ActsAsScopeRoot
      base.extend_scoped! Splash::ActsAsScope::ArraylikeAccess
    end
  end
  
  module ClassMethods
    
    def persister(strategy=nil)
      if strategy == :by_id
        return Splash::Document::ByIdPersister.new(self.namespace,self)
      elsif strategy == :by_id_string
        return Splash::Document::ByIdStringPersister.new(self.namespace,self)
      end
      Splash::Document::Persister.new(self.namespace,self)
    end
    
    def eigenpersister
      self
    end
    
    def try_convert(obj)
      return obj if obj.kind_of? Splash::Documentbase
      return persister.from_saveable(obj)
    end
    
  end
  
end
