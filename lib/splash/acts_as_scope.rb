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
  module ActsAsScope
    
    autoload_all File.join(File.dirname(__FILE__),'acts_as_scope')
    
    include Enumerable
    
    module ArraylikeAccess
      def [](*args)
        if args.size == 1
          # range
          if args.first.kind_of? Range
            range = args.first
            offset = range.first.to_int
            last = range.last.to_int
            if last == -1 and !range.exclude_end?
              return query( :skip => offset )
            end
            if last < -1 
              raise "ranges with negative ends are not supported ( except -1 for no limit )"
            end
            limit = ( last - offset ) + ( range.exclude_end? ? 0 : 1 )
            return query( :limit => limit, :skip => offset )
          elsif args.first.kind_of? Numeric
            return query( :limit => 1, :skip => args.first.to_i ).first
          else
            # id query
            return query( :conditions => {'_id'=>args.first} ).first
          end
        elsif args.size == 2
          offset = args[0].to_int
          limit = args[1].to_int
          return query( :limit => limit, :skip => offset )
        end
        raise "bag arguments #{args.inspect}, expected a range or a limit and an offset"
      end
    end
    
    module HashlikeAccess
      def [](key)
        return query( :conditions => {'_id'=>key} ).first.value
      end
    end
    
    include QueryInterface
    include MapReduceInterface
    
    
    # the following methods have to be defined
    # when including this Module:
    # - collection
    # - scope_root
    
    
    def scope_options
      @scope_options ||= Options.new
    end
    
    def query(options)
      Scope.new(self,scope_options.merge(options))
    end
    
    def all
      clone
    end
    
    CHUNK_SIZE = 10
    
    def each_unchunked(&block)
      if !block
        return Enumerator.new(self,:each_unchunked)
      end
    
      a = block.arity.abs
      
      if a == 2
        old_block = block
        block = lambda{|object| old_block.call(object._id,object) }
      elsif a != 1
        raise "Expected block to have an arity of +-1 or +-2, but got #{block.inspect} (arity: #{block.arity.inspect})"
      end
      
      num_returned = 0
      cursor = self.clone.scope_cursor
      eigenpersister = self.scope_root.eigenpersister
      last = nil
      remaining = (cursor.has_next? && (cursor.limit <= 0 || num_returned < cursor.limit))
      begin
        while remaining
          doc = eigenpersister.from_saveable( cursor.next_document )
          num_returned += 1
          remaining = (cursor.has_next? && (cursor.limit <= 0 || num_returned < cursor.limit))
          last = block.call(doc)
        end
      ensure
        cursor.close()
      end
      return last
    end
    
    def each_chunked(chunk_size=CHUNK_SIZE, &block)
      eigenpersister = self.scope_root.eigenpersister
      batch = eigenpersister.respond_to? :from_saveable_batch
      if chunk_size <= 1 or !batch
        return each_unchunked(&block)
      end
      
      if !block
        return Enumerator.new(self,:each_chunked,chunk_size)
      end
      
      a = block.arity.abs
      
      if a == 2
        block = lambda{|object| block.call(object._id,object) }
      elsif a != 1
        raise "Expected block to have an arity of 1 or 2, but got #{block.inspect} (arity: #{a.inspect})"
      end
      
      num_returned = 0
      cursor = self.clone.scope_cursor
      last = nil
      remaining = (cursor.has_next? && (cursor.limit <= 0 || num_returned < cursor.limit))
      begin
        chunk = []
        while remaining
          chunk << cursor.next_document
          num_returned += 1
          remaining = (cursor.has_next? && (cursor.limit <= 0 || num_returned < cursor.limit))
          if chunk.size == chunk_size or !remaining
            chunk = eigenpersister.from_saveable_batch(chunk)
            last = chunk.each(&block)
            chunk = []
          end
        end
      ensure
        cursor.close()
      end
      return last
    end
    
    alias each each_chunked
    
    def to_a
      result = []
      each do |object|
        result << object
      end
      return result
    end
    
    def to_h
      result = {}
      each do |key,value|
        result[key]=value
      end
      return result
    end
    
    def has_next?
      scope_cursor.has_next?
    end
    
    def next_document
      nd = scope_cursor.next_document
      return nil if nd.nil?
      return self.scope_root.eigenpersister.from_saveable(nd)
    end
    
    def first
      self.limit(1).next_document
    end
    
    def clone
      return Scope.new(self.scope_root,scope_options.dup)
    end
    
    def next_raw_document
      scope_cursor.next_document
    end
    
    def count
      self.clone.scope_cursor.count
    end
    
    alias_method :size, :count
    
    def scope_root?
      false
    end
    
    def +(other_scope)
      Scope.new(self,scope_options.merge(other_scope.scope_options,:or))
    end
    
    def -(other_scope)
    
    end
    
    def <<(object)
      @scope_options.writeback(object)
      if scope_root?
        super(object) if defined? super
      else
        scope_root.<<(object)
        warn "object #{object} was writen to scope #{self} but won't be findable" unless complies_with?(object)
        return object
      end
    end
    
    def complies_with?(object)
      @scope_options.selector.matches?(object)
    end

    def explain
      self.scope_root.collection.find(*find_options).explain()
    end

    def update(*args)
      options = find_options
      self.scope_root.collection.update(options[0],*args)
    end

    def respond_to?(meth, include_private=false)
      load_scope_extensions!
      super
    end
    
    def new(*args,&block)
      if scope_root?
        return super
      end
      obj = scope_root.new(*args,&block)
      @scope_options.writeback(obj)
      return obj
    end
    
    def create(*args,&block)
      obj = self.new(*args,&block)
      obj.insert!
      return obj
    end
    
    def remove!
      return scope_root.collection.remove(*find_options)
    end
    
    def exists?
      sc = self.fieldmode(:none).limit(1).scope_cursor
      result = sc.has_next?
      sc.close
      return result
    end
    
    def empty?
      return !exists?
    end
    
    def any?(&block)
      if block_given?
        Enumerable::Enumerator.new(self).any?(&block)
      else
        return exists?
      end
    end

    protected
      
      def scope_cursor()
        @scope_cursor ||= find!
      end
      
      def unset_scope_cursor()
        @scope_cursor=nil
      end
      
      def query!(options)
        @scope_options = scope_options.merge(options)
      end
    
      def find!
        self.scope_root.collection.find(*find_options)
      end
=begin
      def update!(*args)
        
      end
=end
      def find_options
        selector,options = scope_options.selector,scope_options.options
        return [selector,options]
      end
      
    private
      def load_scope_extensions!
        unless @scope_extesions_loaded
          scope_options.extensions.each do |mod|
            self.extend(mod)
          end
          @scope_extesions_loaded = true
          return true
        end
        return false
      end
      def method_missing(meth,*args,&block)
        if load_scope_extensions!
          return self.send(meth,*args,&block)
        end
        super
      end
  end
end
