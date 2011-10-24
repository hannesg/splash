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
require 'digest/sha1'
require 'securerandom'

class Splash::Password
  
  include Splash::Embed
  
  DIGESTER = Digest::SHA1
  
  attribute 'salt'
  
  attribute 'hash'
  
  def matches?(string)
    DIGESTER.hexdigest("#{string}#{self.salt}") == self.hash
  end
  
  def initialize(str_or_args={})
    if str_or_args.kind_of? String
      slt = SecureRandom.hex
      hash = DIGESTER.hexdigest("#{str_or_args}#{slt}")
      super({'salt'=>slt,'hash'=>hash})
    elsif str_or_args.kind_of? Hash
      super(str_or_args)
    else
      super({})
    end
  end
  
  def self.try_convert(str)
    if str.kind_of? self
      return str
    elsif str.kind_of? String or str.kind_of? Hash
      return self.new(str)
    else
      return nil
    end
  end
  
  
end
