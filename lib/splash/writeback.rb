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
