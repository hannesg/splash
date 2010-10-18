# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::Saveable do
  
  it "should implement a meaningful equal operator" do
    
    class Xy
      
      include Splash::Document
      
    end
    
    original = Xy.new('xkcd'=>'rocks!')
    
    original.store!
    
    Xy.to_a.first.should == original
    
  end
  
  it "should support documents as hash keys" do
    
    class Xyz
      
      include Splash::Document
      
      attribute "i"
      
    end
    
    hash = {}
    
    (1..10).each do |i|
      
      hash[Xyz.new("i"=>i).store!] = i
      
    end
    
    Xyz.each do |xyz|
      
      hash[xyz].should == xyz.i
      
    end
    
  end
  
end
