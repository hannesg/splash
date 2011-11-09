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
#    (c) 2011 by Hannes Georg
#

require 'facets/module/alias_method_chain.rb'
require 'mongo/exceptions.rb'

# A class for error which is classy instead of error-code based.
# This should make it possible to catch errors more selectivly.
module Mongo::Error

  CODES = Hash.new{|hsh,k| hsh[k] = Mongo::Error.const_get("E#{k}".to_sym) }

  def code(*codes)
    if codes.size == 1
      c = codes.first
      CODES[c] = Mongo::Error.const_set("E#{c.to_s}",self)
    else
      codes.each do |c|
        CODES[c] = Mongo::Error.const_set("E#{c.to_s}",Class.new(self))
      end
    end
  end

  class << self
  
    ERROR_REGEXP = /\AE(\d+)\z/
    ERROR_NAME_REGEXP = /(?:\A|::)E(\d+)\z/
    
    def const_missing(name)
      if name.to_s =~ ERROR_REGEXP
        return CODES[$1.to_i] = self.const_set(name, Class.new(Mongo::Error::UnnamedError))
      end
      super
    end
  
  end
  
end

Mongo::MongoDBError.extend(Mongo::Error)

# This class is used for any unnamed error.
class Mongo::Error::UnnamedError < Mongo::MongoDBError

end

# This type is raise when you try to drop a system namespace ( like system.indices ).
class Mongo::Error::CantDropSystemNamespace < Mongo::OperationFailure

  code 12502

end

# This type is raised whenever a key is duplicated.
class Mongo::Error::DuplicateKey < Mongo::OperationFailure

  class Insert < self
  
    code 11000
  
  end
  
  class Update < self
  
    code 11001
  
  end
  
end

class Mongo::Error::CappedCollectionFull < Mongo::OperationFailure

  code 10003

end

class Mongo::MongoDBError

  class << self
  
    def new_with_classy_errors(message = nil, error_code = nil, result = nil)
      if error_code
        return Mongo::Error::CODES[error_code].new_without_classy_errors(message, error_code, result)
      end
      return new_without_classy_errors(message, error_code, result)
    end
  
    alias_method_chain :new, :classy_errors
    
  end

end
