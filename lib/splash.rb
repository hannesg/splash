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
if defined? Splash
  raise "Splash included twice!"
end

require "cautious"
require "combineable"

Dir[File.join(File.dirname(__FILE__),"/standart_extensions/**/*.rb")].each do |path|
  require path
end

module Splash
  autoload_all File.join(File.dirname(__FILE__),'splash')
end
