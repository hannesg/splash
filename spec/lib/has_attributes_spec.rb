require File.join(File.dirname(__FILE__),"../helper")

describe Splash::HasAttributes do
  
  describe "declaration" do
    
    it "should look cool and work" do
      
      class User
        
        include Splash::HasAttributes
        
        
        # simple style
        def_attribute 'name'
        
        # simple with type
        def_attribute 'friends', Splash::Collection.of(User)
        
        def_attribute( 'mails', Splash::Collection.of(String)) do
          
          self.default = Splash::Collection.of(String).new
          
        end
        
      end
      
      User.attributes.should have(3).items
      
      u = User.new
      
      u.name.should be_nil
      
      u.friends.should be_nil
      
      u.mails.should_not be_nil
      u.mails.should be_a(Splash::Collection.of(String))
      
    end
    
  end
  
end