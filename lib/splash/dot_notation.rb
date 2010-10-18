# -*- encoding : utf-8 -*-
module Splash::DotNotation
  
  def get(path)
    Splash::DotNotation.get(self,path)
  end
  
  
  def set(path,value)
    Splash::DotNotation.set(self,path,value)
  end
  
  def self.get(object,path)
    return object if path.nil?
    rest = path
    loop do
      if object.kind_of? Array
        return object.map do |sub|
          Splash::DotNotation.get(sub,rest)
        end
      end
      first,rest = rest.split('.',2)
      if object.kind_of? Hash
        object = object[first]
      else
        object = object.send(first)
      end
      unless rest
        return object
      end
    end
  end
  
  def self.set(object,path,value)
    rest = path
    loop do
      if object.kind_of? Array
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