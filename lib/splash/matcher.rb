module Splash
  
  class Matcher < Hash
    
    Atoms = Hash.new do |hash,key|
      hash[key] = lambda{|value,matcher| false}
    end
    Atoms['$eq'] = lambda{|value,matcher| value == matcher }
    Atoms['$neq'] = lambda{|value,matcher| value != matcher }
    Atoms['$in'] = lambda{|value,matcher| matcher.contains? value }
    Atoms['$nin'] = lambda{|value,matcher| !(matcher.contains? value) }
    Atoms['$lt'] = lambda{|value,matcher| matcher > value }
    Atoms['$leq'] = lambda{|value,matcher| matcher >= value }
    Atoms['$gt'] = lambda{|value,matcher| matcher < value }
    Atoms['$geq'] = lambda{|value,matcher| matcher <= value }
    Atoms['$elemMatch'] = lambda{|value,matcher| Matcher.cast(matcher).matches_any?(value) }
    Atoms['$not'] = lambda{|value,matcher|
      if matcher.kind_of? Regexp
        value !~ matcher
      else
        !Matcher.cast(matcher).matches?(value)
      end
    }
    Atoms['$all'] = lambda{|value,matcher|
      matcher.all? do |sub|
        Matcher.match_atomic(value,sub)
      end
    }
    
    def self.match_atomic(value,matcher)
      if matcher.kind_of? Hash
        matcher.each do |function,arg|
          return false unless Atoms[function].call(value,arg)
        end
      elsif matcher.kind_of? Regexp
        return false unless value =~ matcher
      elsif value.kind_of? Array
        return false unless value.include? matcher
      else
        return false unless value == matcher
      end
      return true
    end
    
    def matches?(object)
      self.each do |key,matcher|
        if key == '$or'
          return false unless matcher.any? do |sub|
            Matcher.cast(sub).matches?(object)
          end
          next
        end
        value = get_value(object,key)
        
        return false unless Matcher.match_atomic(value,matcher)
      end
      return true
    end
    
    def matches_any?(array)
      array.any? do |obj|
        self.matches? obj
      end
    end
    
    def self.cast(hsh)
      return hsh if hsh.kind_of? Matcher
      return self.new.update(hsh) if hsh.kind_of? Hash
      raise "can't convert #{hsh.inspect} to matcher"
    end
    
    def and(other)
      result = Matcher.new
      other.each do |k,v|
        if k == '$or'
          result['$or'] = (self['$or'] || []) + v
        elsif self.key?(k)
          if self[k].kind_of? Hash and v.kind_of? Hash
            result[k] = self[k].merge(v)
          elsif self[k].kind_of? Hash or v.kind_of? Hash
            hsh, simple = v , self[k]
            if simple.kind_of? Hash
              hsh, simple = simple, hsh
            end
            hsh = hsh.dup
            hsh['$all'] ||= []
            hsh['$all'] << simple
            result[k] = hsh
          else
            result[k]={'$all'=>[self[k],v]}
          end
        else
          result[k]=v
        end
      end
      self.each do |k,v|
        result[k]=v unless result.key?(k)
      end
      return result
    end
    
    def or(other)
      Matcher.cast({
        '$or' => (self.dnf + other.dnf)
      })
    end
    
    def dnf
      base = self.dup
      self_or = base.delete('$or',[Matcher.new])
      return self_or.map do |sub|
        sub.and(base)
      end
    end
    
    def self.and(*args)
      result = Matcher.new
      args.each do |arg|
        result = result.and(Matcher.cast(arg)) unless arg.nil?
      end
      return result
    end
    
    protected
      def get_value(object,key)
        key.split('.').each do |part|
          puts part.inspect
          object = object.send(part)
          return nil if object.nil?
        end
        return object
      end
  end
end
