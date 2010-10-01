require File.join(File.dirname(__FILE__),"../helper")

describe Splash::Matcher do
  
  describe "matching" do
    
    it "should work in an easy case" do
      
      a = Splash::AttributedStruct.new
      
      a.foo = "blue"
      
      a.bar = 4
      
      Splash::Matcher.cast(
        'foo' => 'blue',
        'bar' => {'$lt' => 5}
      ).matches?(a).should be_true
      
    end
    
    it "should support the $type opperator" do
      
      class IndecisiveKey
        
        include Splash::Document
        
        attribute 'key'
        
      end
      
      docs = []
      
      values = [:symbol,'str',5,-10,1099511627776,-1099511627776,/regexp/,[['array']],true,false,nil]
      
      values.each do |key|
        # single
        docs << IndecisiveKey.new('key'=>key).store!
        # and combined
        values.each do |key2|
          docs << IndecisiveKey.new('key'=>[key,key2]).store!
        end
      end
      
      values.each do |value|
        
        query = Splash::Matcher.cast('key'=>{'$type'=>BSON.type(value)})
        
        db_result = IndecisiveKey.conditions(query).to_a
        
        matcher_result = docs.find_all do |other_doc|
          query.matches?(other_doc)
        end
        
        (db_result.map(&:_id) - matcher_result.map(&:_id)).should have(0).items
        (matcher_result.map(&:_id) - db_result.map(&:_id)).should have(0).items
        
      end
      
    end
    
  end
  
  describe "merging" do
    
    it "should support merging in a trivial case" do
      
      a = Splash::Matcher.new('name'=>'Max')
      b = Splash::Matcher.new('age'=>20)
      
      a_and_b = a.and b
      
      a_and_b.should == Splash::Matcher.new('name'=>'Max','age'=>20)
      
    end
    
    it "should support merging with overlapping attributes" do
      
      a = Splash::Matcher.new('age'=>{'$lt'=>30})
      b = Splash::Matcher.new('age'=>20)
      
      a_and_b = a.and b
      
      a_and_b.should == Splash::Matcher.new('age'=>{'$all'=>[20],'$lt'=>30})
      
    end
    
  end
  
end