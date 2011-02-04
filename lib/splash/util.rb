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
module Splash::Util
  
  
  def self.calculate_array_updates(from, to, path='')
    
    result = {'$set'=>{},'$unset'=>{}}
    set = result['$set']
    unset = result['$unset']
    
    findices = ( from.respond_to?(:present_indices) ? from.present_indices : from.indices)
    tindices = ( to.respond_to?(:present_indices) ? to.present_indices : to.indices)
    
    if (findices == tindices) and findices.all?{|i| i >= 0}
      findices.each do |i|
        tvalue = to[i]
        fvalue = from[i]
        if tvalue.kind_of? Hash and fvalue.kind_of? Hash
          sub = self.calculate_updates(fvalue,tvalue, Splash::DotNotation.join(path,i.to_s) )
          set.update( sub['$set'] )
          unset.update( sub['$unset'] )
        elsif tvalue.kind_of? Array and fvalue.kind_of? Array
          sub = self.calculate_array_updates(fvalue,tvalue, Splash::DotNotation.join(path,i.to_s) )
          set.update( sub['$set'] )
          unset.update( sub['$unset'] )
        elsif fvalue != tvalue
          set[ Splash::DotNotation.join(path,i.to_s) ] = Splash::Lazy.demand!(to[i])
        end
      end
    else
      set[path] = Splash::Lazy.demand!(to)
    end
    return result
  end
  
  # This method generates the updates
  # required to transform hash 'from' into hash 'to'.
  # These updates can go directly into Mongo::Collection.update.
  def self.calculate_updates(from, to, path='', lazy=true)
    
    if( from.kind_of?(Array) and to.kind_of?(Array) )
      return self.calculate_array_updates(from, to, path)
    end
    
    result = {'$set'=>{},'$unset'=>{}}
    set = result['$set']
    unset = result['$unset']
    #puts "#{from.inspect} => #{to.inspect}"
    #fkeys = from.keys
    #tkeys = to.keys
    fkeys = (lazy and from.respond_to?(:present_keys,false)) ? from.present_keys : from.keys
    tkeys = (lazy and to.respond_to?(:present_keys,false)) ? to.present_keys : to.keys
    deleted = fkeys - tkeys
    added = tkeys - fkeys
    difference = fkeys - deleted
    
    #puts "deleted #{deleted.inspect}"
    #puts "added #{added.inspect}"
    #puts "difference #{difference.inspect}"
    
    
    difference.each do |key|
      tvalue = to[key]
      fvalue = from[key]
      if tvalue.kind_of? Hash and fvalue.kind_of? Hash
        sub = self.calculate_updates(fvalue,tvalue, Splash::DotNotation.join(path,key) )
        set.update( sub['$set'] )
        unset.update( sub['$unset'] )
      elsif tvalue.kind_of? Array and fvalue.kind_of? Array
        sub = self.calculate_array_updates(fvalue,tvalue, Splash::DotNotation.join(path,key) )
        set.update( sub['$set'] )
        unset.update( sub['$unset'] )
      elsif fvalue != tvalue
        set[ Splash::DotNotation.join(path,key) ] = Splash::Lazy.demand!(to[key])
      end
    end
    added.each do |key|
      set[ Splash::DotNotation.join(path,key) ] = Splash::Lazy.demand!(to[key])
    end
    deleted.each do |key|
      unset[ Splash::DotNotation.join(path,key) ] = 1
    end
    return result
  end
  
  
  
end