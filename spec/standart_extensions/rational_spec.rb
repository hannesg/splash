describe Rational do

  it "should be saveable" do
  
    Rational.to_saveable(Rational(2,3)).should == {'numerator'=>2, 'denominator'=>3}
  
    Rational.to_saveable(2).should == {'numerator'=>2, 'denominator'=>1}
    
    Rational.to_saveable("0.5").should == {'numerator'=>1, 'denominator'=>2}
    
    Rational.to_saveable("7/5").should == {'numerator'=>7, 'denominator'=>5}
    
    Rational.to_saveable(nil).should be_nil
    
    Rational.to_saveable("foo").should be_nil
  
  end
  
  it "should be loadeable" do
  
    Rational.from_saveable({'numerator'=>2, 'denominator'=>3}).should == Rational(2,3)
    
    Rational.from_saveable(5).should == Rational(5)
    
    Rational.from_saveable(nil).should be_nil
    
    Rational.from_saveable(Rational(5,7).to_s).should == Rational(5,7)
  
  end

end
