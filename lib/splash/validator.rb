class Splash::Validator
  
  attr_reader :field,:block,:description,:depends
  
  def valid?(object)
    if @block
      return @block.call(object)
    else
      value = object.send(@field)
      if value.respond_to? :valid?
        return value.valid?
      end
    end
    true
  end
  
  def initialize(field, description,options={},&block)
    @field = field
    @block = block
    @description = description
    @depends = (options[:depends] || Set.new)
  end 
  
end