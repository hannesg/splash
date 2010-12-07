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
  
  # In the exclusive Hash you specify which fields
  # can be additionaly loaded. All other fields are
  # considered unavailable.
  module Hash::Exclusive
    include Hash::Base
    def self.extended(base)
      base.instance_eval do
        @lazy_collection ||= nil
        @lazy_id ||= nil
        @lazy_path ||= nil
        @lazy_mutex ||= Mutex.new
        @lazy_complete ||= false
      end
    end
    
    def inspect
      result = []
      self.keys.each do |key|
        result << (key.inspect + ':' + self[key,false].inspect)
      end
      '{' + result.join(', ') + '}'
    end
    
    def clone
      klon = super
      klon.instance_eval do
        @lazy_mutex = @lazy_mutex.clone
      end
      return klon
    end
    
    def present_keys
      keys.select{|k| !lazy? k }
    end
    
    def [](key,load=true)
      v = super(key)
      if load and v.kind_of? Ness
        self.demand!(key)
        return super(key)
      end
      return v
    end
    
    def key?(key,load=true)
      if !load
        return super(key)
      elsif super(key)
        if self.lazy?(key)
          demand!(key)
        end
        return super(key)
      else
        return false
      end
    end
    
    def lazy?(field)
      self[field,false].kind_of? Ness
    end
    
    def lazify(*fields)
      @lazy_mutex.synchronize do
        fields.each do |field|
          unless self.key?(field,false)
            self[field] = HIS_ROYAL_LAZINESS
          end
        end
      end
    end
    
    def unlazify(*fields)
      @lazy_mutex.synchronize do
        fields.each do |field|
          unless self.lazy?(field)
            self.delete(field)
          end
        end
      end
    end
  end
end
end