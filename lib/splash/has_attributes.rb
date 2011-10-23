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
    
    extend Cautious
    extend Combineable
    
    include Dup
    
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
    
    def ==(other)
      if self.class == other.class
        return self.attributes.raw == other.attributes.raw
      end
      return super
    end
    
    module ClassMethods
      
      def alias_attribute(aliaz,real)
        attribute_accessor(aliaz,real)
      end
      
      def attribute_accessor(name,real_name=name)
        self.class_eval <<-CODE, __FILE__, __LINE__
def #{name.to_s}() return attributes[#{real_name.to_s.inspect}] end
def #{name.to_s}=(value) return attributes[#{real_name.to_s.inspect}] = value end
def #{name.to_s}?() return attributes.key? #{real_name.to_s.inspect} end
CODE
      end
      
      def attribute_class
        Splash::Attribute
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
        a = "_attribute_#{name}_persister"
        return Object unless self.respond_to? a
        return send(a)
      end
      
      def attribute_type(name)
        a = "_attribute_#{name}_type"
        return Object unless self.respond_to? a
        return send(a)
      end
      
      def attribute_default(name)
        a = "_attribute_#{name}_default"
        return ::NA unless self.respond_to?(a)
        method = self.send(a)
        return attribute_type(name).instance_eval &method
      end
      
      def attribute_setter(name, value)
        a = "_attribute_#{name}_setter"
        return value unless self.respond_to?(a)
        method = self.send(a)
        return attribute_type(name).instance_exec(value, &method)
      end
      
      def from_raw(data,*args,&block)
        o = self.allocate
        o.attributes.load_raw(data)
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
