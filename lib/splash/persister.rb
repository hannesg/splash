# -*- encoding : utf-8 -*-
module Splash
  module Persister
  
    RAW_TYPES=[String,NilClass,Numeric,FalseClass,TrueClass,BSON::ObjectId,Time,BSON::Code,BSON::DBRef,Symbol]
    
    def self.raw?(value)
      return true if RAW_TYPES.any? do |type| value.class == type end
      if value.kind_of?(Hash) || value.kind_of?(Array)
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
