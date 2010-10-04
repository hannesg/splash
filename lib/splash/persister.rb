# -*- encoding : utf-8 -*-
class Splash::Persister
  
  RAW_TYPES=[String,NilClass,Numeric,FalseClass,TrueClass,BSON::ObjectId,Time]
  
  attr_reader :persisted_class
  
  def read(value)
    return value
  end
  
  def write(value)
    return value
  end
  
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
  
  def initialize(config={},&block)
    self.config= default_config.merge(config)
    if block_given?
      instance_eval &block
    end
  end
  
  def persist_class(klass)
    @persisted_class=klass
  end
  
  def persisted_class()
    @persisted_class
  end
  
  def bind_to(klass)
    
  end
  
  def default(object)
    @config[:default]
  end
  
  def missing(object)
    nil
  end
  
  protected
    def default_config
      {:default=>nil,:read=>nil,:write=>nil}
    end
    def config=(conf)
      @config=conf
    end
end
