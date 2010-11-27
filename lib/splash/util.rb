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
  
  
  # This method generates the updates
  # required to transform hash 'from' into hash 'to'.
  # These updates can go directly into Mongo::Collection.update.
  def self.calculate_updates(from, to, path='')
    result = {'$set'=>{},'$unset'=>{}}
    set = result['$set']
    unset = result['$unset']
    #puts "#{from.inspect} => #{to.inspect}"
    #fkeys = from.keys
    #tkeys = to.keys
    fkeys = from.respond_to?(:present_keys,false) ? from.present_keys : from.keys
    tkeys = to.respond_to?(:present_keys,false) ? to.present_keys : to.keys
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
      elsif fvalue != tvalue
        set[ Splash::DotNotation.join(path,key) ] = to[key]
      end
    end
    added.each do |key|
      set[ Splash::DotNotation.join(path,key) ] = to[key]
    end
    deleted.each do |key|
      unset[ Splash::DotNotation.join(path,key) ] = 1
    end
    return result
  end
  
  
  
end