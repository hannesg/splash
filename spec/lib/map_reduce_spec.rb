# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::MapReduce do
  
  it "should work" do
    
    class Post
      
      include Splash::Document
      
      attribute "tags"
      
    end
    
    tags = [["nice"],["niccer","spam"],["spam"],[],["niccer","nice"],["post"]]
    
    tags.each do |t|
      
      Post.new("tags"=>t).store!
      
    end
    
    map = <<-MAP
function(){
  this.tags.forEach(function(tag){
    emit(tag,1);
  });
}
MAP
    reduce = <<-REDUCE
function(key,values){
  var total = 0;
  values.forEach(function(count){
    total += count
  });
  return total;
}
REDUCE

    mr = Post.map_reduce(map,reduce)
    mr['niccer'].value.should == 2
  end
  
  it "should work with javascript scope" do
    
    class Post
      
      include Splash::Document
      
      attribute "tags"
      
    end
    
    tags = [["nice"],["niccer","spam"],["spam"],[],["niccer","nice"],["post"]]
    
    tags.each do |t|
      
      Post.new("tags"=>t).store!
      
    end
    
    map = <<-MAP
function(){
  this.tags.forEach(function(tag){
    emit(tag,1);
  });
}
MAP
    reduce = <<-REDUCE
function(key,values){
  var total = 0;
  values.forEach(function(count){
    total += count
  });
  return total;
}
REDUCE
    Post.map_reduce(map,reduce)['niccer'].value.should == 2
  end
  
  describe "Permanent" do
    
    it "should work in a trivial case" do
      
      class Post
      
        include Splash::Document
        
        attribute "tags"
        
        Tags = Splash::MapReduce[Post,<<-MAP,<<-REDUCE]
function(){
  this.tags.forEach(function(tag){
    emit(tag,1);
  });
}
MAP
function(key,values){
  var total = 0;
  values.forEach(function(count){
    total += count
  });
  return total;
}
REDUCE
        
      end
      
      tags = [["nice"],["niccer","spam"],["spam"],[],["niccer","nice"],["post"]]
    
      tags.each do |t|
        
        Post.new("tags"=>t).store!
        
      end
      
      Post::Tags.refresh!
      
      Post::Tags.collection.name.should == "post.tags"
      
      Post::Tags['niccer'].value.should == 2
      
    end
    
    it "should support not giving a map/reduce function" do
      
      class MapReducePicture
        
        include Splash::Document
        
        attribute "width"
        attribute "height"
        attribute "type", String
        
        class Sizes < Splash::MapReduce[self]
          
          def self.map
            return <<JS
function(){
  var size = this.height * this.width;
  emit(this.type,{count:1,max: size, min: size, avg: size});
}
JS
          end
          def self.reduce
            return <<JS
function(key,values){
  var result = {count:0,max: 0, min: 0, avg: 0};
  values.forEach(function(value){
    result.avg = ( (result.count * result.avg)+(value.count * value.avg) )/(result.count + value.count)
    if( result.min == 0 || result.min > value.min ){
      result.min = value.min;
    }
    if( result.max < value.max){
      result.max = value.max;
    }
    result.count += value.count;
  });
  return result;
}
JS
          end
        
        end
        
        [{'width'=>200,'height'=>100,'type'=>'png'},
          {'width'=>10,'height'=>40,'type'=>'png'},
          {'width'=>1000,'height'=>100,'type'=>'jpg'}
          ].each do |pic|
          
          MapReducePicture.new(pic).store!
          
        end
        
        MapReducePicture::Sizes.refresh!
        
        MapReducePicture::Sizes.collection.name.should == "map_reduce_picture.sizes"
        
        MapReducePicture::Sizes.count.should == 2
        
      end
    
    end
    
  end
  
end