# -*- encoding : utf-8 -*-
module Splash
  module ActsAsScope
    
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
            limit = ( last - offset ) - ( range.exclude_end? ? 1 : 0 )
            return query( :limit => limit, :skip => offset )
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
    
    include QueryInterface
    
    
    # the following methods have to be defined
    # when including this Module:
    # - collection
    # - scope_root
    
    
    def scope_options
      @scope_options ||= Splash::Scope::Options.new
    end
    
    def query(options)
      Scope.new(self,scope_options.merge(options))
    end
    
    def dup
      
    end
    
    def all
      clone
    end
    
    def each(&block)
      a = block.arity
      if a == 1
        self.clone.scope_cursor.each do |o|
          yield Saveable.load(o,self)
        end
      elsif a == 2
        self.clone.scope_cursor.each do |o|
          l = Saveable.load(o,self)
          yield(l._id,l.value)
        end
      end
      self
    end
    
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
      return Saveable.load(nd,self.scope_root)
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
    
    def scope_root?
      false
    end
    
    def <<(object)
      @scope_options.writeback(object)
      if scope_root?
        super(object)
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

    def map_reduce(map,reduce,opts={})
      self.query(opts.only([:query,:sort,:limit])).map_reduce!(map,reduce,opts)
    end

    protected
      def map_reduce!(map,reduce,opts)
        opts = opts.only([:finalize,:out,:keeptemp,:verbose])
        query, options = find_options
        opts[:query] = query
        opts = opts.merge(options)
        return Splash::MapReduceResult.new(self.scope_root.collection.map_reduce(map,reduce,opts))
      end
    
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
      
      def update!(*args)
        
      end
      
      def find_options
        selector,options = scope_options.selector,scope_options.options
        if self.scope_root.kind_of? Splash::Saveable
          selector["Type"]=self.scope_root.to_s
        end
        return [selector,options]
      end
      
  end
end
