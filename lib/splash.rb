if defined? Splash
  raise "Splash included twice!"
end

Dir[File.join(File.dirname(__FILE__),"/splash/standart_extensions/*.rb")].each do |path|
  require path
end

module Splash
  
  DIR = File.dirname(__FILE__)
  
  autoload_all File.join(File.dirname(__FILE__),'splash')
  

  
end

