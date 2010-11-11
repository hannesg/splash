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
class User
  
  include Splash::Document
  
  namespace :foreign
  
  attribute 'name', String
  
  attribute 'active'
  
  extend_scoped! do
    
    def active
      
      where('active'=>true)
      
    end
    
    def inactive
      
      where('active'=>false)
      
    end
    
  end
  
  
  def posts
    Post.where('author'=>self)
  end
  
  def comments
    Comment.where('author'=>self)
  end
  
  PostStat = Splash::MapReduce[Post,<<MAP,<<REDUCE]
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
  
end