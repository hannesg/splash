require "logger"
require "delegate"
module Splash
  class Namespace
    
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
      
    end
    
    class << self
      attr_accessor :logger
    end
    
    self.logger = ::Logger.new(STDOUT)
    self.logger.level = Logger::WARN
    
    def self.default
      @default ||= self.new
    end
    
    def self.default=(value)
      @default = value
    end
    
    def initialize(uri='mongodb://localhost/splash')
      match = URI_MATCHER.match(uri)
      if match.nil?
        @db = Mongo::Connection.from_uri(uri,:logger=>LoggerDelegator.new)
      else
        @db = Mongo::Connection.new(match[1],match[2].length==0 ? nil : match[2].to_i,:logger=>LoggerDelegator.new).db(match[3])
      end
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
      @class_collection_map ||= {}
      @top_classes ||={}
      return @class_collection_map[klass] if( @class_collection_map.key? klass)
      
      
      classes=Saveable.get_class_hierachie(klass)
      
      collection=@db.collection(classes.last.to_s.gsub(/(<?[a-z])([A-Z])/){ |c| c[0,1]+"_"+c[1,2].downcase }.gsub("::",".").downcase)
      
      @top_classes[collection.name] = classes.last
      
      classes.each do |klass|
        @class_collection_map[klass]=collection
      end
      
      return collection
    end
    
    def class_for(collection_name)
      @top_classes[collection_name]
    end
    
    def dereference(dbref)
      self.class_for(dbref.namespace)[dbref.object_id]
    end
    
  end
end