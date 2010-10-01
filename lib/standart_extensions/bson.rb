require "bson"
module BSON
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
          return [16]
        else
          # ouch, 64 bit ints!
          return [18]
        end
      end
      @class_to_type.each do |other_class,value|
        if object.kind_of? other_class
          return value
        end
      end
      return nil
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