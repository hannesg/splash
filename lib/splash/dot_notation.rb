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
module Splash::DotNotation
  
  DOT = '.'.freeze
  
  NUMERIC = /^\d+$/.freeze
  
  
  class Enumerator
    
    include Enumerable
    
    def initialize(object,path)
      @object = object
      @path = path
    end
    
    def each(options={},&block)
      options = {:iterate_last=>true}.merge(options)
      traverse(@object,[],Splash::DotNotation.parse_path(@path),block,false,options)
    end
    
    def map!(options={},&block)
      options = {:iterate_last=>true}.merge(options)
      traverse(@object,[],Splash::DotNotation.parse_path(@path),block,true,options)
    end
    
    def final(object,history,key,block,set,options)
      o = Splash::DotNotation.get_key(object,key)
      if options[:iterate_last] and o.kind_of? Array
        traverse(o,history + [key],[],block,set,options)
        return o
      end
      value = block.call(history + [key],o)
      if set
        Splash::DotNotation.set_key(object, key, value)
      end
      return value
    end
    
    def traverse(object,history,future,block,set=false,options={})
      if object.kind_of?(Array)
        if future.first.kind_of?(Numeric)
          if future.one?
            value = block.call(history + [future.first], object[future.first])
            if set
              object[future.first] = value
            end
            return value;
          end
          traverse(object[future.first], history +[future.first], future.tail,block, set,options)
        else
          i = 0
          l = object.length
          while i < l
            traverse(object, history , [i] + future, block, set,options)
            i+=1
          end
        end
        return object
      elsif future.none?
        return block.call(history,object)
      elsif future.one?
        final(object,history,future.first,block,set,options)
        return object
      elsif object.kind_of? Hash
        traverse(object[future.first],history + [future.first], future.tail,block, set,options)
        return object
      else
        traverse(object.send(future.first),history + [future.first], future.tail,block, set,options)
        return object
      end
    end
    
  end
  
  class Recursor
    
    class Position < Struct.new(:past,:future)
    end
    
    include Enumerable
    
    def initialize(object,path)
      @object = object
      @path = Splash::DotNotation.parse_path(path)
    end
    
    def each
      obj = @object
      past = []
      future = @path.dup
      while true
        yield(obj,Position.new(past.dup,future.dup))
        if future.any?
          k = future.unshift
          obj = Splash::DotNotation.get_key(obj,k)
          past.push( k )
        else
          return obj
        end
      end
    end
    
  end
  
  def sub(path,start_or_range,length=-1)
    
  end
  
  def self.join(path,sub)
    return sub if path.empty?
    return path + '.' + sub
  end
  
  def self.pop(path)
    ld = path.rindex(DOT)
    return '',path if ld.nil?
    return path[0...ld], path[(ld+1)..-1]
  end
  
  def get(path)
    Splash::DotNotation.get(self,path)
  end
  
  def set(path,value)
    Splash::DotNotation.set(self,path,value)
  end
  
  def self.parse_path(path)
    if path.kind_of? Array
      return path
    end
    if path.kind_of? Numeric
      return [path]
    end
    if path == ''
      return []
    end
    path.split(DOT).map do |e|
      e =~ NUMERIC ? e.to_i : e
    end
  end
  
  def self.get_key(object,key)
    #if !object.available?
    #  return object
    #els
    if object.kind_of? Array
      if key.kind_of? Numeric
        return object[key]
      end
      return object.map do |sub|
        get_key(sub,key)
      end
    elsif object.kind_of? Hash
      return NA unless object.key? key
      return object[key]
    elsif object.respond_to? :dot_notation_get
      return object.dot_notation_get(key)
    else
      return NA if key.kind_of? Numeric
      return NA unless object.respond_to? key
      return object.send(key)
    end
  end
  
  def self.set_key(object,key,value)
    if object.kind_of? Array
      if key.kind_of? Numeric
        return object[key]=value
      end
      return object.map do |sub|
        set_key(sub,key,value)
      end
    elsif object.kind_of? Hash
      return object[key]=value
    elsif object.respond_to? :dot_notation_set
      return object.dot_notation_set(key,value)
    else
      return object.send(key+"=",value)
    end
  end

  def self.get(object,path)
    return object if path.nil?
    parse_path(path).each do |p|
      object = get_key(object,p)
    end
    return object
  end
  
  def self.set(object,path,value)
    return value if path.nil?
    pp = parse_path(path)
    last = pp.pop
    pp.each do |p|
      object = get_key(object,p)
    end
    return set_key(object,last,value)
    rest = path
    loop do
      if object.kind_of? Array
        first,sub_rest = rest.split('.',2)
        if first =~ /^\d+$/
          return Splash::DotNotation.set(object[first.to_i],sub_rest,value)
        end
        return object.map do |sub|
          Splash::DotNotation.set(sub,rest,value)
        end
      end
      first,rest = rest.split('.',2)
      if rest
        if object.kind_of? Hash
          object = object[first]
        else
          object = object.send(first)
        end
      else
        if object.kind_of? Hash
          return object[first] = value
        else
          return object.send(first + '=',value)
        end
      end
    end
  end
  
end
