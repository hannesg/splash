class Post
  
  include Splash::Document
  
  attribute 'title', String
  
  attribute 'body', String
  
  attribute 'rating', Numeric do
    
    default {0}
    
  end
  
  attribute 'author', User
  
  attribute 'tags', Array do
    
    default :new
    
  end
  
end