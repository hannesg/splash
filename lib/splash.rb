# -*- encoding : utf-8 -*-
if defined? Splash
  raise "Splash included twice!"
end

Dir[File.join(File.dirname(__FILE__),"/standart_extensions/*.rb")].each do |path|
  require path
end

module Splash
  
  autoload_all File.join(File.dirname(__FILE__),'splash')
  
end
