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
    
    def each(&block)
      traverse(@object,[],Splash::DotNotation.parse_path(@path),block)
    end
    
    def traverse(object,history,future,block)
      if object.kind_of?(Array)
        if future.first.kind_of?(Numeric)
          traverse(object[future.first], history +[future.first], future.rest,block)
        else
          i = 0
          for sub in object
            traverse(sub, history + [i], future, block)
            i+=1
          end
        end
      elsif future.empty?
        block.call(history,object)
      elsif object.kind_of? Hash
        traverse(object[future.first],history + [future.first], future.rest,block)
      else
        traverse(object.send(future.first),history + [future.first], future.rest,block)
      end
    end
    
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
    path.split(DOT).map do |e|
      e =~ NUMERIC ? e.to_i : e
    end
  end
  
  def self.get_key(object,key)
    if object.kind_of? Array
      if key.kind_of? Numeric
        return object[key]
      end
      return object.map do |sub|
        get_key(sub,key)
      end
    elsif object.kind_of? Hash
      return object[key]
    else
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