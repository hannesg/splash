# -*- encoding : utf-8 -*-
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    (c) 2010 by Hannes Georg
#
require "rubygems"
require "bundler/setup"

Bundler.require(:default,:development)

require "mongo"

Splash::Namespace.default = Splash::Namespace.new('mongodb://localhost/splash-testing')
Splash::Lazy::Collection.invade!

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
