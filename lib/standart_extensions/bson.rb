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
require "bson"
module BSON
  
  class OrderedHash
    
    def dup
      result = super
      result.instance_eval do
        @ordered_keys = @ordered_keys.dup
      end
      return result
    end
    
  end
  
  module ClassTypeConverter
    
    MAX_INT32 = 2**31-1
    
    MIN_INT32 = -(2**31)
    
    INT32 = MIN_INT32 .. MAX_INT32
    
    def self.map!(*args)
      args.each_slice(2) do |klass,type|
        @class_to_type[klass] << type
        @type_to_class[type] << klass
      end
    end
    
    def self.classes(type)
      @type_to_class[type]
    end
    
    def self.types_for_class(klass)
      @class_to_type.each do |other_class,value|
        if other_class >= klass
          return value
        end
      end
      return nil
    end
    
    def self.types_for_object(object)
      if object.kind_of? Integer
        if INT32.include?(object)
          # ouch, 64 bit ints!
          return [16].to_set
        else
          # ouch, 64 bit ints!
          return [18].to_set
        end
      end
      found_class = Object
      found_type = nil
      @class_to_type.each do |other_class,value|
        if object.kind_of? other_class and !(other_class > found_class)
          found_class = other_class
          found_type = value
        end
      end
      return found_type
    end
    
    def self.reset!
      @class_to_type = Hash.new{|hash,key| hash[key] = Set.new }
      @type_to_class = Hash.new{|hash,key| hash[key] = Set.new }
    end
  end
  
  ClassTypeConverter.reset!
  
  ClassTypeConverter.map!(
    Float, 1,
    
    String, 2,
    
    # Object:
    Hash, 3,
    
    Array, 4,
    
    BSON::Binary, 5,
    
    # Undefined (deprecated)
    # NilClass, 6,
    
    BSON::ObjectId, 7,
    
    # Boolean:
    TrueClass, 8,
    FalseClass, 8,
    
    Time, 9,
    
    # Null:
    NilClass, 10,
    
    Regexp, 11,
    
    BSON::DBRef, 12,
    
    Symbol, 14,
    
    BSON::Code, 15,
    
    Integer, 16,
    Integer, 18,
    
    BSON::MaxKey, 127,
    
    BSON::MinKey, -1
  )
  
  def self.types_for_object(object)
    ClassTypeConverter.types_for_object(object)
  end
  
  def self.types_for_class(klass)
    ClassTypeConverter.types_for_class(klass)
  end
  
  def self.types(klass_or_object)
    if klass_or_object.kind_of? Module
      ClassTypeConverter.types_for_class(klass_or_object)
    else
      ClassTypeConverter.types_for_object(klass_or_object)
    end
  end
  
  def self.type(klass_or_object)
    self.types(klass_or_object).first
  end
end
