# -*- encoding : utf-8 -*-
module Splash
  module Persister
  
    RAW_TYPES=[String,NilClass,Numeric,Float,Regexp,Fixnum,FalseClass,TrueClass,BSON::ObjectId,Time,BSON::Code,BSON::DBRef,BSON::Binary,Symbol]
    
    def self.raw?(value)
      return true if RAW_TYPES.any? do |type| value.class == type end
      if value.kind_of?(Hash)
        value.each do |key,val|
          return false unless self.raw?(key)
          return false unless self.raw?(val)
        end
        return true
      elsif value.kind_of?(Array)
        value.each do |sub|
          return false unless self.raw?(sub)
        end
        return true
      end
      return false
    end

  end

end
