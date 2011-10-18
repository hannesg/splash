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

describe Splash::EmbededCollection do
  
  it "should work in a trivial case" do
    
    base = Splash::Namespace.default.collection('embed_base')
    embed = Splash::EmbededCollection.new('embeds',base)
    
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
    embed = Splash::EmbededCollection.new('embeds', base)
    
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
      include Splash::HasEmbededCollections
      
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
    
    puts DocumentWithEmbeds1.first.inspect
    
    
    doc = DocumentWithEmbeds1.create(
      'body' => 'bla',
      'comments' => [ DocumentWithEmbeds1::Comment.new('body'=>'blub') ]
    )
    
    puts DocumentWithEmbeds1.to_a.inspect
    
    DocumentWithEmbeds1.first.comments.each do |com|
      puts com.body.inspect
    end
    
    
  end
  
  describe "slices" do
  
    it "should be queryable" do
    
      DocumentWithEmbeds1.create("comments"=>[ DocumentWithEmbeds1::Comment.new('x'=>1),DocumentWithEmbeds1::Comment.new('x'=>2) ] )
    Splash::Namespace.debug do
      dwe = DocumentWithEmbeds1.first
    
      dwe.comments.should have(2).items
    
      dwe.comments.conditions('x' => 1).should have(1).item
    end
    end
  
  end
  
end
