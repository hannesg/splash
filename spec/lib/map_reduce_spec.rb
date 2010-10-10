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
      
      Post::Tags['niccer'].value.should == 2
      
    end
    
    
  end
  
end