# -*- encoding : utf-8 -*-
require File.join File.dirname(__FILE__), "object"
require File.join File.dirname(__FILE__), "module"
class Hash
  
  DEEP_MERGER=proc{|key,value,value2|
    if( value.kind_of?(Hash) && value2.kind_of?(Hash) )
      value.merge(value2,&DEEP_MERGER)
    else
      value2
    end
  }
  
  def deep_merge(k)
    return self if k.nil?
    merge(k,&DEEP_MERGER)
  end
  
  def deep_merge!(k)
    return self if k.nil?
    merge!(k,&DEEP_MERGER)
  end
  
  def only(keys)
    self.reject{|key,val| !keys.include? key}
  end
  
  def except(keys)
    self.reject{|key,val| keys.include? key}
  end
  
  def hashmap
    self.inject({}) do |newhash, (k,v)|
      newhash[k] = yield(k, v)
      newhash
    end
  end
  
  def +(hsh)
    self.merge(hsh)
  end
  
end
