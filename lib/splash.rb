# -*- encoding : utf-8 -*-
if defined? Splash
  raise "Splash included twice!"
end

Dir[File.join(File.dirname(__FILE__),"/standart_extensions/**/*.rb")].each do |path|
  require path
end

class NotGivenClass
  class << self
    def instance
      return (@instance ||= self.new)
    end
  end
end
NotGiven = NotGivenClass.instance
class NotGivenClass
  class << self
    undef :new, :allocate
  end
end

module Splash
  
  
  
  
  autoload_all File.join(File.dirname(__FILE__),'splash')
  
end
