require "rubygems"
require "bundler/setup"

require File.join(File.dirname(__FILE__),"../../Humanized/lib/humanized")

culture=Humanized::Culture.new
culture.default_case = :nominativ
culture.converter = Humanized::Converter.new({})


Humanized::Culture.native=culture
Humanized::Culture.current=culture

require File.join(File.dirname(__FILE__),"../lib/splash")