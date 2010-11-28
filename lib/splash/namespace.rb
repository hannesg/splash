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
    
    class ClassNotFound < NameError
    end
    
    
    URI_MATCHER = /^mongodb:\/\/([^\/:@]+)(:\d+|)\/(.*)/.freeze
    
    #LOGGER = ::Logger.new(STDOUT)
    #LOGGER.level = Logger::WARN
    
    attr_reader :db
    
    class LoggerDelegator < Logger
      
      def initialize
        super(nil)
      end
      
      def add(*args,&block)
        Splash::Namespace.logger.add(*args,&block)
      end

      def <<(msg)
        Splash::Namespace.logger << msg
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
    
    def self.request_id
      Mongo::Connection.class_eval '@@current_request_id'
    end
    
    def self.count_requests
      old_q = self.request_id
      yield
      new_q = self.request_id
      return new_q - old_q
    end
    
    def self.debug
      begin
        self.logger.level, old = Logger::DEBUG, self.logger.level
        yield
      ensure
        self.logger.level = old
      end
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
    
    def initialize(uri_or_db='mongodb://localhost/splash')
      if uri_or_db.kind_of? Mongo::DB
        @db = uri_or_db
      else
        match = URI_MATCHER.match(uri_or_db)
        if match.nil?
          @db = Mongo::Connection.from_uri(uri_or_db,:logger=>LoggerDelegator.new)
        else
          @db = Mongo::Connection.new(match[1],match[2].length==0 ? nil : match[2].to_i,:logger=>LoggerDelegator.new).db(match[3])
        end
        @uri = uri_or_db
      end
      
      #@class_collection_map = {}
      #@top_classes = {}
    end
    
    def to_s
      @uri
    end
    
    def clear!
      @db.collections.each do |collection|
        begin
          collection.drop
        rescue Mongo::OperationFailure
        end
      end
      #@top_classes.clear
      #@class_collection_map.clear
      return true
    end
    
    def collection_for(klass)
      thiz = self
      last_named = nil
      klass.self_and_superclasses do |k|
        unless k.respond_to?(:namespace)
          break
        end
        unless k.namespace == thiz
          raise "Namespace mismatch: #{k} ( namespace: #{k.namespace.to_s} ) is a Superclass of #{klass} ( namespace: #{thiz.to_s} )."
        end
        if k.named?
          last_named = k
        end
        if last_named and k.instance_variable_defined?('@is_collection_base')
          return collection(self.class_to_collection_name(last_named.to_s))
        end
      end
      raise "Couldn't find a collection for #{klass}!"
      return nil
    end
    
    def class_for(collection_name)
      begin
        return collection_to_class_name(collection_name).split('::').inject(Kernel) do |memo,obj|
          memo.const_get(obj)
        end
      catch NameError => e
        raise ClassNotFound.new('No Class found for ' + collection_name +'. Error received: ' + e.message)
      end
    end
    
    def dereference(dbref)
      begin
        klass = self.class_for(dbref.namespace) 
        return klass.eigenpersister.from_saveable( @db.dereference(dbref) )
      rescue ClassNotFound => e
        warn e.message
      end
    end
    
    attr_reader :db
    
    def collection(name)
      Splash::Collection.new(self,name)#@db.collection(name)
    end
  end
end
