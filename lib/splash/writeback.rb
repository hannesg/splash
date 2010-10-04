# -*- encoding : utf-8 -*-
class Splash::Writeback < Hash
  
  def writeback_methods
    @writeback_methods ||= []
  end
  
  def self.merge(*args)
    args.compact!
    return nil unless args.any?
    result = self.new
    args.each do |arg|
      result = result.merge(self.cast(arg))
    end
    return result
  end
  
  def self.cast(hash_or_proc)
    return hash_or_proc if hash_or_proc.kind_of? self
    return self[hash_or_proc] if hash_or_proc.kind_of? Hash
    if hash_or_proc.kind_of? Proc
      r = self.new
      r.writeback_methods << hash_or_proc
      return r
    end
    raise "can't convert #{hash_or_proc} into Writeback'"
  end
  
  def writeback(to)
    self.each do |key,value|
      to.send("#{key.to_s}=",value)
    end
    @writeback_methods.each do |meth|
      meth.call(to)
    end
    return to
  end
  
  def merge(other)
    result = super(other)
    result.writeback_methods.push(*self.writeback_methods)
    result.writeback_methods.push(*other.writeback_methods)
    return result
  end
  
end
