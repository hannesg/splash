# -*- encoding : utf-8 -*-
require "rubygems"
require "bundler/setup"

Bundler.require(:default,:development)

Splash::Namespace.default = Splash::Namespace.new('mongodb://localhost/splash-testing')

RSpec.configure do |config|
  config.before(:each) {
    Splash::Namespace.default.clear!
  }
end

=begin
require File.join(File.dirname(__FILE__),"../../Humanized/lib/humanized")

culture=Humanized::Culture.new
culture.default_case = :nominativ
culture.converter = Humanized::Converter.new({})


Humanized::Culture.native=culture
Humanized::Culture.current=culture
=end
