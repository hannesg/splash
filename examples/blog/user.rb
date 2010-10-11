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