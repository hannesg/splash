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
module Splash
  module HasAttributes
    
    autoload_all File.join(File.dirname(__FILE__),'has_attributes')
    
    ATTRIBUTE_GETTER_REGEXP = /^([a-zA-Z_]+)$/.freeze
    ATTRIBUTE_SETTER_REGEXP = /^([a-zA-Z_]+)=$/.freeze
    ATTRIBUTE_QUERY_REGEXP = /^([a-zA-Z_]+)\?$/.freeze
    
    class Attributes < BSON::OrderedHash
      
      include HasAttributes::GeneratesUpdates
      
      alias_method :read, :[]
      alias_method :write, :[]=
      
      def load(attrs)
        attrs.each do |key,value|
          self[key]=value
        end
      end
      
      def dirty?(key)
        return true if @deleted_keys.include? key
        return self.key? key
      end
      
      def clean?(key)
        !dirty?(key)
      end
      
      # this is a brain transplantation!
      def load_raw(raw)
        #@sync.synchronize(Sync::EX){
          flush!
          @raw = raw
        #}
      end
      
      def [](key)
        #@sync.synchronize(Sync::SH){
        return ::NA if( @deleted_keys.include? key )
        return super if( self.key? key )
          
          #@sync.synchronize(Sync::EX){
            #return super if( self.key? key )
            if( @raw.key? key )
              value = @class.attribute_persister(key).from_saveable(@raw[key])
            else
              value = @class.attribute_default(key)
            end
            if ::NA == value
              self.delete(key)
            else
              self.write(key,value)
              @deleted_keys.delete key
            end
            return value
          #}
        #}
      end
      
      def key?(k)
        return false if @deleted_keys.include? k
        return super
      end
      
      def []=(key,value)
        #@sync.synchronize(Sync::EX){
          if ::NA == value
            self.delete(key)
          else
            self.write(key,value)
            @deleted_keys.delete key
          end
        #}
      end
      
      def delete(key)
        super
        @deleted_keys << key
      end
      
      def initialize(klass)
        super()
        @class = klass
        @raw = {}
        @sync = Sync::Dummy.new
        @deleted_keys = Set.new
        #complete!
      end
      
      def raw
        return write_into!(@raw.deep_clone)
      end
      
      def type(key)
        return @class.attribute(key)
      end
      
      def each
        @sync.synchronize(Sync::SH){
          super
        }
      end
      
      def write_back!
        @sync.synchronize(Sync::EX){
          write_into!(@raw)
          @deleted_keys.clear
        }
        return self
      end
      
      protected
        def complete!
          keys = Set.new
          matcher = /^attribute_([a-z_]+)_default$/
          @class.methods do |meth|
            if match = matcher.match(meth.to_s)
              a = match.to_a
              unless @not_given.include?(a[1]) or self.key?(a[1])
                self[a[1]]=@class.send(meth)
              end
            end
          end
          return self
        end
        
        def flush!
          self.replace({})
        end
        
        def write_into!(target={})
          self.each do |key,value|
            target[key]=@class.attribute_persister(key).to_saveable(value)
          end
          @deleted_keys.each do |key|
            target.delete(key)
          end
          return target
        end
    end
    
    extend Concerned
    extend Combineable
    
    combined_with(HasCollection) do |base|
      base.class_eval do
        def save!
          self.update!(self.attributes.updates)
          self.attributes.write_back!
        end
      end
    end
    
    
    def attributes
      @attributes ||= Attributes.new(self.class)
    end
    
    def attribute(name)
      self.class.attribute(name)
    end
    
    def respond_to?(meth, include_private=false)
      return true if meth =~ ATTRIBUTE_QUERY_REGEXP
      return true if meth =~ ATTRIBUTE_SETTER_REGEXP
      super(meth, include_private)
    end
    
    def inspect
      "#{self.class.to_s}{#{attributes.raw.inspect}}"
    end
    
    def to_raw
      attributes.raw
    end
    
    def method_missing(meth,*args,&block)
      if meth == 'initialize'
        return super
      end
      ms = meth.to_s
      if( args.size == 0 and ms =~ ATTRIBUTE_GETTER_REGEXP )
        return attributes[$1]
      elsif( args.size == 1 and ms =~ ATTRIBUTE_SETTER_REGEXP )
        # setter
        return attributes[$1]=args.first
      elsif( args.size == 0 and ms =~ ATTRIBUTE_QUERY_REGEXP )
        return attributes.key?($1)
      end
      super
    end
    
    def initialize(attr={})
      self.attributes.load(attr)
      super()
    end
    
    module ClassMethods
      
      def attribute_accessor(name)
        self.class_eval <<-CODE, __FILE__, __LINE__
def #{name.to_s}() return attributes[#{name.to_s.inspect}] end
def #{name.to_s}=(value) return attributes[#{name.to_s.inspect}] = value end
CODE
      end
      
      def attribute_class
        @attribute_class ||= Class.new(Splash::Attribute)
      end
      
      def attribute(name,*args,&block)
        name = name.to_s
        attr = attribute_class.new(self,name)
        if args.any? or block_given?
          attr.make(*args, &block)
        end
        attribute_accessor(name)
        return attr
      end
      
      def attribute_persister(name)
        a = "attribute_#{name}_persister"
        return Object unless self.respond_to? a
        return send(a)
      end
      
      def attribute_type(name)
        a = "attribute_#{name}_type"
        return Object unless self.respond_to? a
        return send(a)
      end
      
      def attribute_default(name)
        a = "attribute_#{name}_default"
        return ::NA unless self.respond_to?(a)
        method = self.send(a)
        return attribute_type(name).instance_eval &method
      end
      
      def from_raw(data,*args,&block)
        o = self.allocate
        o.attributes.load_raw(data)
        if o.respond_to?(:initialize,true)
          o.send(:initialize,*args,&block)
        end
        return o
      end
      
      def new_with_defaults(*args,&block)
        o = self.allocate
        o.attributes.complete!
        if o.respond_to?(:initialize,true)
          o.send(:initialize,*args,&block)
        end
        return o
      end
      
      def new_without_defaults(*args,&block)
        o = self.allocate
        if o.respond_to?(:initialize,true)
          o.send(:initialize,*args,&block)
        end
        return o
      end
      
      def to_saveable(value)
        value = value.to_raw unless value.nil?
        value = super(value) if defined? super
        return value
      end
      
      def from_saveable(value)
        return value if value.nil?
        return self.from_raw(value)
      end
      
      def from_saveable_batch(docs,*)
        docs.map{|doc| from_saveable(doc) }
      end
      
    end
  end
end
