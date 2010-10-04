# -*- encoding : utf-8 -*-
module Splash::ActsAsCollection
  
  include Enumerable
  
  def self.of(klass)
    m = Module.new
    s = self
    m.class_eval do
      include(s)
    end
    m.collection_class = klass
    return m
  end
  
  class << self
    def included(base)
      if base.kind_of? Class
        base.extend(ClassMethods)
      else
        base.extend(SubModuleMethods)
      end
      
    end
  end
  
  module SubModuleMethods
    attr_accessor :collection_class
    
    def included(base)
      base.extend(ClassMethods)
      s = self
      base.instance_eval do
        @collection_class = s.collection_class
      end
    end
  end
  
  module ClassMethods
    attr_reader :collection_class
  end
  
  def create(*args,&block)
    object=self.class.collection_class.new(*args,&block)
    self << object
    return object
  end
  
  def accepts?(object)
    return object === collection_class
  end
  
  def include?(object)
    accepts?(object) && super
  end
end
