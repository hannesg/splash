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
class Splash::EmbededCollection
  
  class Persister < Array::Persister
  
    def from_saveable(val)
      return val
    end
  
    def to_saveable(val)
      return nil if val.nil?
      entry_class = @base_class.entry_class
      return val.map{|e|
        if e.kind_of? entry_class
          e.demand_id!
          @entry_persister.to_saveable(e)
        else
          e
        end
      }
    end
  
  end
  
  module CollectionExtension
  
    def persister
      return Splash::EmbededCollection::Persister.new(self, self.entry_class.eigenpersister)
    end
  
  end
  
  def self.of(klass)
    c = Array.of(klass)
    c.extend(CollectionExtension)
    return c
  end
  
  class Cursor
    
    SELECT_ALL = lambda{|x| true }
    
    def initialize(arr,options)
      @array = arr
      @position = 0
      @has_more = true
      @limit = options[:limit] || -1
      @selector = options[:selector]
      @seeked = false
    end
    
    def limit
      @limit
    end
    
    def close
     
    end
    
    def seek_next_valid!
      return true if @seeked
      until @array[@position].nil? or @position >= @limit or @selector.call(@array[@position])
        @position += 1
      end
      @seeked = true
      return !(@array[@position].nil? or @position >= @limit)
    end
    
    def invalidate_seeked!
      @seeked = false
    end
    
    def next_document
      return nil unless seek_next_valid!
      doc = @array[@position]
      invalidate_seeked!
      return doc
    end
    
    def has_next?
      return seek_next_valid!
    end
    
    def each
      while( has_next? )
        yield next_document
      end
    end
    
    def count
      @array.count(&@selector)
    end
    
  end
  
  class Slice < self
    
    def initialize(path, basecollection, id, loaded = [])
      super(path, basecollection)
      @dbref = BSON::DBRef.new(basecollection.name,id)
      @loaded = loaded
    end
    
    def insert(doc,*args)
      doc['_owner'] = @dbref
      super(doc,*args)
    end
    
    def find(selector={},options={})
      skip = options[:skip] || 0
      limit = options[:limit] || -1
      if skip == 0 and limit == -1
        return Cursor.new(@loaded,{:limit=>limit, :selector=>Splash::ActsAsScope::Matcher.cast(selector)})
      end
      return Cursor.new(@loaded[skip..(skip + limit)],{:limit=>limit, :selector=>Matcher.cast(selector)})
    end
    
  end

  REDUCE = '
function(key,result){
  return result[0];
}
'
  def initialize(path, basecollection)
    raise "Path must be a kind of String but got #{path.inspect}" unless path.kind_of? String
    @basecollection, @path = basecollection, path
    @pk_factory ||= BSON::ObjectId
  end
  
  def name
    @basecollection.name + ':' + @path
  end
  
  def insert(doc,options={})
    unless( doc.key? '_owner' )
      raise "I don't know where I should save the Embed #{doc.inspect}. Please provide a key '_owner'."
    end
    doc = @pk_factory.create_pk(doc)
    owner = doc.delete('_owner')
    @basecollection.update({'_id'=>owner.object_id},{'$push'=>{@path=>doc}},options)
  end
  
  def save(doc,options={})
    if doc.key? '_id'
      update_document(doc['_id'],doc.except('_owner'),:upsert => true, :safe => options[:safe])
    else
      insert(doc,:safe => options[:safe])
    end
  end
  
  # WARNING: This updates only one embed per document!
  def update(selector,updates,options={})
    @basecollection.update({@path=>{'$elemMatch'=>selector}}, rekey_updates(updates), options)
  end
  
  def remove(selector={}, opts={})
    @basecollection.update({@path=>{'$pull'=>selector}}, opts)
  end
  
  def update_document(id,updates,options={})
    self.update({'_id'=>id}, updates, options)
  end
  
  def delete_document(id)
    @basecollection.update(rekey_selector({'_id'=>id}), {'$pull'=>{@path=>{'_id'=>id}}} )
  end
  
  def find_document(id)
      map = "
function(){
  var docid = this._id;
  this[#{@path.inspect}].forEach(function(doc){
    if( ObjectId(#{id.to_s.inspect}).equals(doc._id) ){
      emit(docid,doc);
    }
  });
}"
    result = @basecollection.map_reduce(map,REDUCE,:query=>rekey_selector({'_id'=>id}),:out=>{:inline=>1},:raw=>1 )
    doc = result["results"][0]
    return nil if doc.nil?
    value = doc['value']
    value['_owner'] = BSON::DBRef.new(@basecollection.name,doc['_id'])
    return value
  end
  
  def slice(id,values=[])
    return Slice.new(@path,@basecollection,id,values)
  end
  
protected
  
  def rekey_selector(hash)
    hash.rekey{|k| Splash::DotNotation.join(@path, k) }
  end
  
  def rekey_updates(hash,nesting=true)
    p = Splash::DotNotation.join(@path,'$')
    result = {}
    hash.each do |k,v|
      if( nesting and k[0] == ?$ )
        result[k]={}
        v.each do |subk, subv|
          result[k][Splash::DotNotation.join(p,subk)] = subv
        end
      else
        result['$set'] ||= {}
        result['$set'][p] ||= {}
        result['$set'][p][k] = v
      end
    end
    return result
  end
  
end
