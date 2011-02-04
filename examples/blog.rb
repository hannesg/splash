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

user = User.new('name'=>'User','active'=>true).store!

p1 = admin.posts.new( 'title' => 'Why are memory leaks so ugly?', 'body' => 'because they suck!' , 'rating' => 2).store!

p2 = admin.posts.new( 'title' => 'What to post next?', 'body' => 'no idea' , 'rating' => -1).store!

c1 = p1.comments.new('comment'=>'I like them.','author'=>user).store!
#puts c1.inspect#.store!

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

puts Post.to_a.inspect

10.times do
  # retrive some things
  
  # fetch all posts
  Post.to_a
  
  # map reduce!
  User::PostStat.refresh!
  
  User::PostStat[admin].value
  
  temp[admin].value
  
end
