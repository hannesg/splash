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
require "set"
module Splash
module Lazy
  
  # In the inclusive Hash you specify
  # which fields are loaded. All other are
  # considered reloadable.
  module Hash::Inclusive
    include Hash::Base
    def self.extended(base)
      base.instance_eval do
        @lazy_collection = nil
        @lazy_id = nil
        @lazy_path = nil
        @lazy_fields = Set.new
        @lazy_complete = false
        @lazy_mutex = Mutex.new
      end
    end
  
    def inspect
      result = []
      self.keys.each do |key|
        result << (key.inspect + ':' + self[key,false].inspect)
      end
      '{' + result.join(', ') + (complete? ? '' : ' and maybe more ... ' ) + '}'
    end
  
    def clone
      klon = super
      klon.instance_eval do
        @lazy_mutex = @lazy_mutex.clone
        @lazy_fields = @lazy_fields.clone
      end
      return klon
    end
  
    def initialize_laziness(collection,id,path)
      @lazy_collection, @lazy_id, @lazy_path = collection, id, path
      return self
    end
  
    def [](key,load=true)
      if load and lazy?(key)
        self.demand!(key)
      end
      return super(key)
    end
    
    def delete(key)
      @lazy_mutex.synchronize do
        @lazy_fields << key
        return super
      end
    end
    
    def key?(key,load=true)
      if load
        demand!(key)
      end
      return super(key)
    end
    
    def lazy?(k)
      !key?(k,false) and !@lazy_fields.include?(k)
    end
    
    def unlazify(*keys)
      @lazy_mutex.synchronize do
        @lazy_fields += (keys.reject{|k| self.key?(k,false)})
      end
    end
  end
end
end