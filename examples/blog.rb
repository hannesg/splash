# -*- encoding : utf-8 -*-
# This file will include 
require 'rubygems'
require 'bundler/setup'

Bundler.require(:default)
Splash::Namespace.default = Splash::Namespace.new('mongodb://localhost/splash-example-blog')
Splash::Namespace::NAMESPACES[:foreign] = Splash::Namespace.new('mongodb://localhost/splash-example-blog-foreign')

# let's build a blog software!
$:.unshift File.expand_path File.dirname(__FILE__)

autoload :User, "blog/user"
autoload :Post, "blog/post"
autoload :Comment, "blog/comment"

admin = User.new('name' => 'Admin', 'active' => true).store!

admin.posts.new( 'title' => 'Why are memory leaks so ugly?', 'body' => 'because they suck!' , 'rating' => 2).store!

admin.posts.new( 'title' => 'What to post next?', 'body' => 'no idea' , 'rating' => -1).store!

temp = Post.map_reduce <<MAP,<<REDUCE
  function(){
    emit(this.author,{count:1,avg_rating:this.rating});
  }
MAP
  function(key,values){
    var result = {count:0,avg_rating:0};
    values.forEach(function(value){
      var sum = value.count + result.count;
      result.avg_rating = ((result.avg_rating*result.count) + (value.avg_rating*value.count)) / sum;
      result.count = sum;
    });
    return result;
  }
REDUCE

10.times do
  # retrive some things
  
  # fetch all posts
  Post.to_a
  
  # map reduce!
  User::PostStat.refresh!
  
  User::PostStat[admin].value
  
  temp[admin].value
  
end
