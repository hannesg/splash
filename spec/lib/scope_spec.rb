require File.join(File.dirname(__FILE__),"../helper")

describe Splash::ActsAsScope do
  
  describe "nesting" do
    
    it "should support a trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
        extend_scoped! do
          def jpeg
            conditions('type'=>'jpeg')
          end
          
          def wider_than(wd)
            conditions('width'=>{'$gt'=>wd})
          end
          
          def heigher_than(hd)
            conditions('height'=>{'$gt'=>wd})
          end
        end
        
      end
      
      Picture.new('type'=>'jpeg','width'=>200,'height'=>200).store!
      Picture.new('type'=>'gif','width'=>200,'height'=>200).store!
      Picture.new('type'=>'jpeg','width'=>400,'height'=>200).store!
      Picture.new('type'=>'jpeg','width'=>100,'height'=>200).store!
      Picture.new('type'=>'png','width'=>200,'height'=>100).store!
      Picture.new('type'=>'png','width'=>150,'height'=>20).store!
      
      Picture.jpeg.wider_than(300).count.should == 1
      
    end
    
  end
  
  
  describe "write back" do
    
    it "should support a trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
      end
      
      jpegs = Picture.conditions('type'=>'jpeg').writeback('type'=>'jpeg')
      
      p = Picture.new
      
      jpegs << p
      
      jpegs.to_a.should include p
      
    end
    
    it "should support another trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
      end
      
      jpegs = Picture.where('type'=>'jpeg')
      
      p = Picture.new
      
      jpegs << p
      
      jpegs.to_a.should include p
      
    end
    
    it "should support the third trivial case" do
      
      class Picture
        
        include Splash::Document
        
        attribute 'type'
        attribute 'width'
        attribute 'height'
        
      end
      
      jpegs = Picture.where('type'=>'jpeg')
      
      p = jpegs.create
      
      jpegs.to_a.should include p
      
    end
    
  end
  
  describe "arraylike access" do
    
    it "should support ranges" do
      class Foo
        include Splash::Document
        
        attribute "i"
        
      end
      i = 1
      20.times do
        f = Foo.new("i"=>i)
        f.store!
        i+=1
      end
      
      Foo[5..15].to_a.should have(10).items
      Foo[5..-1].to_a.should have(15).items
      Foo[5...15].to_a.should have(9).items
    end
    
    it "should support skip with offset" do
      class Foo
        include Splash::Document
      end
      i = 1
      20.times do
        f = Foo.new("i"=>i)
        f.store!
        i+=1
      end
      
      Foo[5,10].to_a.should have(10).items
      
    end
  end
  
  describe "map reduce" do
    
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
  end
  
end