# -*- encoding : utf-8 -*-
require "logger"
require "delegate"
module Splash
  class Namespace
    
    NAMESPACES = Hash.new do |hash,key|
      if( key == :default )
        hash[:default] = Namespace.new
      else
        raise "unknow namespace #{key.inspect}"
      end
    end
    
    URI_MATCHER = /^mongodb:\/\/([^\/:@]+)(:\d+|)\/(.*)/.freeze
    
    #LOGGER = ::Logger.new(STDOUT)
    #LOGGER.level = Logger::WARN
    
    attr_reader :db
    
    class LoggerDelegator < Delegator
      
      def initialize
        super(Splash::Namespace.logger)
      end
      
      def __getobj__
        Splash::Namespace.logger
      end

      def __setobj__(obj)
        Splash::Namespace.logger=obj
      end
      
    end
    
    class << self
      attr_accessor :logger
    end
    
    self.logger = ::Logger.new(STDOUT)
    self.logger.level = Logger::WARN
    
    def self.default
      NAMESPACES[:default]
    end
    
    def self.default=(value)
      NAMESPACES[:default] = value
    end
    
    def class_to_collection_name(klass_name,recheck = true)
      cn = klass_name.gsub(/(<?[a-z])([A-Z])/){ |c| c[0,1]+"_"+c[1,2].downcase }
      cn.gsub!(/::([A-Z])/){|d| "." + (d[2,1].downcase) }
      cn[0...1] = cn[0...1].downcase
      if recheck
        raise "#{klass_name} won't be findable as #{cn} ( got: #{self.collection_to_class_name(cn,false)} )" if self.collection_to_class_name(cn,false) != klass_name
      end
      return cn
    end
    
    def collection_to_class_name(collection_name, recheck = true)
      kn = collection_name.gsub(/_([a-z])/){|c| c[1,2].upcase }
      kn.gsub!(/\.[a-z]/){|c| '::'+c[1,1].upcase}
      kn[0...1] = kn[0...1].upcase
      if recheck
        raise "#{collection} won't find a class #{kn} ( got: #{self.class_to_collection_name(kn,false)} )" if self.class_to_collection_name(kn,false) != collection_name
      end
      return kn
    end
    
    def initialize(uri='mongodb://localhost/splash')
      match = URI_MATCHER.match(uri)
      if match.nil?
        @db = Mongo::Connection.from_uri(uri,:logger=>LoggerDelegator.new)
      else
        @db = Mongo::Connection.new(match[1],match[2].length==0 ? nil : match[2].to_i,:logger=>LoggerDelegator.new).db(match[3])
      end
      @class_collection_map = {}
      @top_classes = {}
    end
    
    def clear!
      @db.collections.each do |collection|
        begin
          collection.drop
        rescue Mongo::OperationFailure
        end
      end
      return true
    end
    
    def collection_for(klass)
      return @class_collection_map[klass] if( @class_collection_map.key? klass)
      
      
      classes=[]
      
      thiz = self
      
      klass.self_and_superclasses do |k|
        if @class_collection_map.key? k
          collection = @class_collection_map[k]
          classes.each do |sk|
            @class_collection_map[sk]=collection
          end
          return collection
        elsif k.named? and k.respond_to?(:namespace) && k.namespace == thiz
          classes.push(k)
        else
          break
        end
      end
      
      @class_collection_map.key? classes.last
      
      collection=@db.collection(self.class_to_collection_name(classes.last.to_s))
      
      @top_classes[collection.name] = classes.last
      
      classes.each do |klass|
        @class_collection_map[klass]=collection
      end
      
      return collection
    end
    
    def class_for(collection_name)
      return @top_classes[collection_name] if @top_classes[collection_name]
      return @top_classes[collection_name] = Kernel.const_get(collection_to_class_name(collection_name))
    end
    
    def dereference(dbref)
      self.class_for(dbref.namespace).conditions('_id'=>dbref.object_id).first
    end
    
    def collection(name)
      @db.collection(name)
    end
    
    def register(klass,collection,top=true)
      collection = self.collection(collection) if collection.kind_of? String
      @class_collection_map[klass] = collection
      if top
        @top_classes[collection.name] = klass
      end
    end
    
  end
end
