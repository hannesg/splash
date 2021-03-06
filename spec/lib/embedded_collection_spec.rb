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
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

module X
  def answer
    4
  end
end


describe Splash::EmbeddedCollection do
  
  it "should work in a trivial case" do
    
    base = Splash::Namespace.default.collection('embed_base')
    embed = Splash::EmbeddedCollection.new('embeds',base)
    
    doc = {'embeds'=>[
       {'_id'=>BSON::ObjectId.new(),'text'=>'Not Me','rating'=>4},
       {'_id'=>BSON::ObjectId.new(),'text'=>'Nice One!','rating'=>1},
       {'_id'=>BSON::ObjectId.new(),'text'=>'Bad Boy','rating'=>6}
     ]};
    
    base.save(doc)
    
    id = doc['embeds'][1]['_id']
    
    e = embed.find_document(id)
    e.should_not be_nil
    e['text'].should == 'Nice One!'
    embed.update_document(id,{'$set'=>{'text'=>'Gets even nicer!'}})
    e = embed.find_document(id)
    e.should_not be_nil
    e['text'].should == 'Gets even nicer!'
    
    e['something_else'] = 'Not that bad, either.'
    
    embed.save(e)
    
    e = embed.find_document(id)
    
    e.should_not be_nil
    e['text'].should == 'Gets even nicer!'
    e['something_else'].should == 'Not that bad, either.'
    
    embed.delete_document(id)
    
    e = embed.find_document(id)
    e.should be_nil
    
  end
  
  it "should support DBRefs" do
    
    base = Splash::Namespace.default.collection('embed_base')
    embed = Splash::EmbeddedCollection.new('embeds', base)
    
    doc = {'embeds'=>[
       {'_id'=>BSON::ObjectId.new(),'text'=>'Not Me'},
       {'_id'=>BSON::ObjectId.new(),'text'=>'Nice One!'},
       {'_id'=>BSON::ObjectId.new(),'text'=>'Bad Boy'}
     ]};
    
    base.save(doc)
    
    id = doc['embeds'][1]['_id']
    
    dbref = BSON::DBRef.new(embed.name,id)
    
    doc = Splash::Namespace.default.raw_dereference(dbref)
    doc['_id'].should == id
    doc['text'].should == 'Nice One!'
    
  end
  
  
  it "should have a cool syntax" do
    
    
    class DocumentWithEmbeds1
      
      include Splash::Document
      include Splash::HasEmbeddedCollections
      
      class Comment
        
        include Splash::Document
        
        collection DocumentWithEmbeds1.collection.embed('comments')
        
        attribute 'body'
        
      end
      
      attribute 'body'
      
      embeds 'comments', :class => Comment
      
    end
    
    d = DocumentWithEmbeds1.new( {'body'=>'Nooooooice!'})
    d.store!
    d.comments.new('body'=>'Looolz!').store!
    
    dd = DocumentWithEmbeds1.first
    
    Splash::Namespace.count_requests{
      dd.comments.to_a
    }.should == 0
    
    
    c2 = DocumentWithEmbeds1::Comment.new( {'body'=>'Yeeesss'})
    
    dd.comments << c2
    
    #dd.store!
    
    doc = DocumentWithEmbeds1.create(
      'body' => 'bla',
      'comments' => [ DocumentWithEmbeds1::Comment.new('body'=>'blub') ]
    )
    
    
    yielder = lambda{}
    
    com = []
    
    DocumentWithEmbeds1.first.comments.should have(2).items
    DocumentWithEmbeds1.first.comments.each do |comment|
      com << comment
    end
    
    com.should have(2).items
    
    DocumentWithEmbeds1::Comment.collection.find.each do |comment|
    
      comment['_id'].should be_kind_of(BSON::ObjectId)
      DocumentWithEmbeds1::Comment.conditions('_id'=>comment['_id']).to_a.should have(1).item
    
    end
    
  end
  
  it "should work" do
  
    doc = DocumentWithEmbeds1.new( {'body'=>'Nooooooice!'})
    
    doc.comments << DocumentWithEmbeds1::Comment.new('body'=>'bla')
  
  end
  
  describe "standalone" do
    
    it "should be queryable" do
    
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
      
      DocumentWithEmbeds1::Comment.conditions('x'=>2).to_a.should have(3).items
    
      DocumentWithEmbeds1::Comment.conditions('x'=>2).size.should == 3
    
    end
    
    it "should be rewindable" do
    
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
      
      
      cur = DocumentWithEmbeds1::Comment.collection.find('x'=>2)
      
      cur.collect{ |d| d['x'] }.should == [2,2,2]
    
      cur.collect{ |d| d['x'] }.should == []
      
      cur.rewind!
      
      cur.collect{ |d| d['x'] }.should == [2,2,2]
    
    end
    
    
  end
  
  describe "slices" do
  
    it "should be queryable" do
    
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )

      dwe = DocumentWithEmbeds1.first
    
      dwe.comments.should have(2).items
    
      dwe.comments.conditions('x' => 1).should have(1).item

    end
    
    it "should be a scope root" do
    
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
      
      dwe = DocumentWithEmbeds1.first
      
      dwe.comments.should be_scope_root
    
    end
    
    it "should support skip and selectors" do
    
      DocumentWithEmbeds1.create("comments"=>(1..50).map{|x| DocumentWithEmbeds1::Comment.new('x'=>x) } )
      
      dwe = DocumentWithEmbeds1.first
      
      com = dwe.comments.conditions('x'=>{'$gt'=>10}).query(:skip=>10,:limit=>20)
      com.should have(20).items
      
      com.collect(&:x).should == (21..40).to_a
    
    end
  
  end
  
  describe "collection names" do
  
    it "should work" do
    
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1) ] )
    
      ref = DocumentWithEmbeds1::Comment.first._dbref
      
      Splash::Namespace.default.class_for(ref.namespace).should == DocumentWithEmbeds1::Comment
      
      DocumentWithEmbeds1::Comment.persister.from_saveable(ref.to_s).should == DocumentWithEmbeds1::Comment.first
      
    end
  
  end
  
end
