class Splash::Connection
  def initialize(host,db)
    @host=host
    @db=db
  end
  
  def get(id)
    Net::HTTP.start("localhost", 5984){|http|
      http.get('/splash/'+id)
    }.body.parse_json
  end
  
  def put(id,val)
    id = id.to_s
    req=Net::HTTP::Put.new('/splash/'+id)
    req.set_content_type("application/json")
    Net::HTTP.start("localhost", 5984){|http|
      http.request(req,val.to_json)
    }.body
  end
  
  def uuid
    
  end
  
end