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
module Splash
  class Lazy::Array < Array
    
    def [](*args)
      #return super if complete?
      raise "[] expects at least one argument, but none given" if args.none?
      start, length = args
      unless( length.nil? )
        start = start..(start+length-1)
      end
      if( start.kind_of? Range )
        self.demand!(start)
        result = ::Array.new
        normalize(start).each do |i|
          result << @lazy_values[i] if @lazy_values.key? i
        end
        return result
      else
        self.demand!(start..start)
        return @lazy_values[normalize(start..start).begin]
      end
    end
    
    def at(index)
      return super if complete?
      self.demand!(index..index)
      return @lazy_values[normalize(index..index).begin]
    end
    
    def clear
      @lazy_complete = true
      super
    end
    
    def each_index(&block)
      if @lazy_length
        (0...@lazy_length).each(&block)
      else
        complete!
        super
      end
    end
    
    def fetch(*args)
      self.demand!(args.first)
      super
    end
    
    def insert(index,args)
      if( index < 0 )
        self.complete!
      end
      super
    end
    
    def first(*args)
      if args.none?
        self.demand!(0..0)
      else
        self.demand!(0..(args.first-1))
      end
      return super
    end
    
    def last(*args)
      if args.none?
        return self[-1]
      else
        return self[(-args.first)..(-1)]
      end
    end
    
    # TODO: write a 'values_at' method
    WRAPPED_METHODS = [:&, :*, :+, :-, :<< , :<=>, :==, :assoc, :collect, :collect!, :compact, :compact!, :concat, :delete,
      :delete_at, :delete_if, :each, :empty?, :eql?, :flatten, :flatten!, :hash, :include?, :index, :indexes,
      :indices,  :join, :length, :map, :nitems, :pack, :pop, :push, :rassoc, :reject, :reject!, :replace, :reverse,
      :reverse!, :reverse_each, :rindex,:select, :shift, :size,:slice!, :sort, :sort!, :to_a, :to_ary, :to_s,
      :transpose, :uniq, :uniq!, :unshift, :values_at, :zip, :|]
    
    WRAPPED_METHODS.each do |meth|
      self.class_eval <<RB
def #{meth}(*args)
  complete!
  super
end
RB
    end
    
    def initialize(fetcher)
      super()
      @fetcher = fetcher
      @lazy_values, @lazy_mutex = Hash.new, Mutex.new
      @lazy_complete = false
      @lazy_length = nil
      #return self
    end
    
    def complete?
      @lazy_complete
    end
    
    def integrate(subset,values)
      return if values.size == 0
      if( subset.count > values.size )
        # okay, we got less than we wanted, so we can now calculate the length
        if subset.begin < 0
          # from the end
          @lazy_length =  values.size - subset.end - 1
        else
          # from the start
          @lazy_length = subset.begin + values.size
        end
        # now we can cleanup the fetched values
        @lazy_values.keys.each do |k|
          if k < 0
            if !@lazy_values.key?(@lazy_length + k)
              v = @lazy_values[k]
              @lazy_values[@lazy_length + k] = v
              self[@lazy_length + k] = v
            end
            @lazy_values.delete(k)
          end
        end
      end
      k = 0
      normalize(subset).each do |i|
        break if k >= values.size
        @lazy_values[i] = values[k]
        if i >= 0
          self[i] = values[k]
        end
        k += 1
      end
      if @lazy_length
        if (0...@lazy_length).all?{|i| @lazy_values.key? i }
          @lazy_complete = true
        end
      end
    end
    
    def complete!
      return if complete?
      if @lazy_mutex.nil?
        @lazy_mutex
      end
      @lazy_mutex.synchronize do
        return if complete?
        #fetcher = Lazy::ArrayFetcher.new(@lazy_collection,@lazy_id,@lazy_path,{})
        result = @fetcher.all
        self.integrate(0..result.size,result)
        @lazy_complete = true
      end
    end
    
    def lazy?(key)
      return false if complete?
      return false if @lazy_values.key?(key)
      if @lazy_length
        # test if the key is out of the fetchable range
        return false if key > @lazy_length
        return false if key < (-1 - @lazy_length )
        return false if @lazy_values.key?( self.complementary_index(key) )
      end
      return true
    end
    
    def complementary_index(index)
      if index < 0
        return @lazy_length + index
      else
        return index - @lazy_length
      end
    end
    
    def demand!(subset)
      return if complete?
      subset = normalize(subset)
      @lazy_mutex.synchronize do
        return if complete?
        min, max = subset.select{|i| self.lazy? i}.minmax
        # require 
        unless min.nil? or max.nil?
          # load
          #fetcher = Lazy::ArrayFetcher.new(@lazy_collection,@lazy_id,@lazy_path,[])
          result = @fetcher[min..max]
          self.integrate(min..max,result)
          #docs = @lazy_collection.find_without_lazy({'_id'=>@lazy_id},{:fields=>{'_id'=>1,@lazy_path => {'$slice'=>[min,max-min+1]}}})
          #if docs.has_next?
          #  doc = docs.next_document
          #  result = DotNotation.get(doc,@lazy_path)
          #  if result.available?
          #    self.integrate(min..max,result)
          #  end
          #end
        end
      end
    end
    def normalize(range)
      if range.exclude_end?
        range = (range.begin)..(range.end-1)
      end
      if range.begin < 0
        if @lazy_length
          if range.begin < -@lazy_length
            range = 0..(@lazy_length + range.end)
          else
            range = (@lazy_length + range.begin)..(@lazy_length + range.end)
          end
        else
          raise "Begin and end must have the same signum for lazy arrays." if range.end >= 0
        end
      else
        if @lazy_length and range.end >= @lazy_length
          range = (range.begin)..(@lazy_length-1)
        end
        raise "Begin and end must have the same signum for lazy arrays." if range.end < 0
      end
      return range
    end
  end
end