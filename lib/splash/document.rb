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
module Splash::Document
  
  class Persister
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
      elsif value.kind_of? String
        return @class.conditions('_id' => BSON::ObjectId.from_string(value) ).first
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
  
  
  include Splash::Saveable
  include Splash::HasAttributes
  include Splash::HasCollection
  include Splash::Callbacks
  
  with_callbacks! :store!
  
  #include Splash::Validates
  
  class << self
    def included(base)
      
      included_modules.each do |mod|
        begin
          mod.included(base)
        rescue NoMethodError
        end
      end
      
      super(base)
      
      base.instance_eval do
        extend Splash::ActsAsScopeRoot
        
        def included(base)
          Splash::Document.included(base)
          super(base)
        end
        
        def inherited(child)
          if child.named? and !child.has_own_collection?
            child.conditions!("Type"=>child.to_s)
          end
        end
        
        def get_class_hierachie(klass)
          base=[]
          begin
            if klass.named?
              base << klass
            end
            #return base unless klass.instance_of? Class
            klass = klass.superclass
          end while ( klass < Splash::HasAttributes )
          return base
        end
        
        def persister(strategy=nil)
          if strategy == :by_id
            return Splash::Document::ByIdPersister.new(self.namespace,self)
          elsif strategy == :by_id_string
            return Splash::Document::ByIdStringPersister.new(self.namespace,self)
          end
          Splash::Document::Persister.new(self.namespace,self)
        end
        
        def eigenpersister
          Splash::Embed::Persister.new(self)
        end
        
        extend_scoped! Splash::ActsAsScope::ArraylikeAccess
        
      end
    end
  end
  
end
