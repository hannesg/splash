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
module Splash::ActsAsScope
  
  class Matcher < Hash
    
    WHERE = '$where'
    
    OR = '$or'
    
    NOT = '$not'
    
    ATOMS = Hash.new do |hash,key|
      hash[key] = lambda{|value,matcher| false}
    end
    ATOMS['$neq'] = lambda{|value,matcher| value != matcher }
    ATOMS['$in'] = lambda{|value,matcher| matcher.contains? value }
    ATOMS['$nin'] = lambda{|value,matcher| !(matcher.contains? value) }
    ATOMS['$lt'] = lambda{|value,matcher| matcher > value }
    ATOMS['$leq'] = lambda{|value,matcher| matcher >= value }
    ATOMS['$gt'] = lambda{|value,matcher| matcher < value }
    ATOMS['$geq'] = lambda{|value,matcher| matcher <= value }
    ATOMS['$elemMatch'] = lambda{|value,matcher| Matcher.cast(matcher).matches_any?(value) }
    ATOMS['$not'] = lambda{|value,matcher|
      if matcher.kind_of? Regexp
        value !~ matcher
      else
        !Matcher.cast(matcher).matches?(value)
      end
    }
    ATOMS['$all'] = lambda{|value,matcher|
      matcher.all? do |sub|
        Matcher.match_atomic(value,sub)
      end
    }
    ATOMS['$type'] = lambda{|value,matcher|
      if value.kind_of? Array
        value.any? do |sub|
          BSON.types_for_object(sub).include? matcher
        end
      else
        BSON.types_for_object(value).include? matcher
      end
      }
    
    
    def self.match_atomic(value,matcher)
      if matcher.kind_of? Hash
        matcher.each do |function,arg|
          return false unless ATOMS[function].call(value,arg)
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
        if key == OR
          return false unless matcher.any? do |sub|
            Matcher.cast(sub).matches?(object)
          end
          next
        elsif key == WHERE
          # 
          # johnson anyone?
          # 
          return true
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
        if k == OR
          result[OR] = (self[OR] || []) + v
        elsif k == WHERE
          if self.key?(k) # ierkssss!
            warn "$where can't be merged!"
          end
          result[k]=v
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
    
    def invert
      d = self.dup
      n = d.delete(NOT,Matcher.new)
      n[NOT]= d
      return Matcher.cast(n)
    end
    
    def or(other)
      Matcher.cast({
        OR => (self.dnf + other.dnf)
      })
    end
    
    def dnf
      base = self.dup
      self_or = base.delete(OR,[Matcher.new])
      return self_or.map do |sub|
        sub.and(base)
      end
    end
    
    def self.and(*args)
      args.compact!
      return nil unless args.any?
      result = Matcher.new
      args.each do |arg|
        result = result.and(Matcher.cast(arg))
      end
      return result
    end
    
    protected
      def get_value(object,key)
        key.split('.').each do |part|
          object = object.send(part)
          return nil if object.nil?
        end
        return object
      end
  end
end
