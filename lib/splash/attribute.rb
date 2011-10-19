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
class Splash::Attribute
  
  def default(fn=nil,*args,&block)
    if block_given?
      set('default'){ block }
    elsif !fn.nil?
      set('default'){ lambda{|type| type.send(fn,*args)} }
    end
  end
  
  def setter(fn=nil,*args,&block)
    if block_given?
      set('setter'){ block }
    elsif !fn.nil?
      set('setter'){ lambda{|obj| send(fn,obj,*args)} }
    end
  end
  
  def this
    self
  end
  
  def has?(key)
    @class.respond_to?("_attribute_#{@name}_#{key}")
  end
  
  def get(key)
    @class.send("_attribute_#{@name}_#{key}")
  end
  
  def set(key,&block)
    @setter.call("_attribute_#{@name}_#{key}",&block)
  end
  
  def initialize(klass,name)
    @class, @name = klass, name
    @setter = (class << @class; method(:define_method); end)
  end
  
  def make(t=Object,&block)
    if !has?('type') or t > Object
      self.type = t
    end
    instance_eval &block if block_given?
  end
  
  def type= t
    self.persister = t.persister
    if t.respond_to? :default
      self.default(:default)
    end
    if t.respond_to? :try_convert
      self.setter(:try_convert)
    end
    @type = t
    set('type'){ t }
  end
  
  def type
    @type ||= get('type')
  end
  
  def persister=(t)
    @persister = t
    set('persister'){ t }
  end
  
  alias_method :persisted_by, :persister=
  
  def persister
    @persister ||= get('persister')
  end
  
  # persisting interface
  def from_saveable(value)
    persister.from_saveable(value)
  end
  
  def to_saveable(value)
    persister.to_saveable(value)
  end
  
  # type interface
  def missing
    self.default
  end
  
  def writeable?
    true
  end
  
  def initial_value
    return type.initial_value if type && type.respond_to?(:initial_value)
    ::NA
  end
  
  def before_write(value)
    return type.before_write(value) if type && type.respond_to?(:before_write)
    value
  end
  
  def alias_for(name)
    
  end
  
  def method_missing(meth, *args, &block)
    nm = 'attribute_' + meth.to_s
    if @class.respond_to? nm
      return @class.send(nm,@name,*args,&block)
    else
      super
    end
  end
  
  def respond_to?(meth, include_private=false)
    nm = 'attribute_' + meth.to_s
    if @class.respond_to? nm
      return true
    else
      super
    end
  end
  
end
