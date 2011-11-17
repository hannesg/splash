describe Mongo::Error do

  it "should catching by code even for named errors" do
  
  
    begin
    
    
    ensure Mongo::Error::E12502
      
    end
  
  end

end
