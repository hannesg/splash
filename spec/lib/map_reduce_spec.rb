# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::MapReduceResult do
  
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
    Post.map_reduce(map,reduce)['niccer'].should == 2
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
    Post.map_reduce(map,reduce)['niccer'].should == 2
  end
  
end