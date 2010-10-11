class Comment
    
  include Splash::Document
  
  attribute 'post', Post
  
  attribute 'body', String
  
  attribute 'author', User
  
end