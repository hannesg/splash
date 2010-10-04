module Splash
  
  class UpdatedAt < Time
    
    def self.initial_value
      return Time.now
    end
    
    def self.before_write(value)
      return Time.now
    end
    
  end
  
end