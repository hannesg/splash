class String
  def to_bson
    BSON::ObjectID.from_string(self)
  end
end