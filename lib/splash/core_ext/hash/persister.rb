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
class Hash
  class Persister

    attr_accessor :key_persister, :entry_persister

    def from_saveable(val)
      return nil if val.nil?
      nu=@base_class.new
      val.inject(nu){|memo,(key,entry)|
        memo[ @key_persister.from_saveable(key) ] = @entry_persister.from_saveable(entry)
        memo
      }
    end
    
    def to_saveable(val)
      return nil if val.nil?
      val.inject({}){|memo,(key,entry)|
        memo[ @key_persister.to_saveable(key) ] = @entry_persister.to_saveable(entry)
        memo
      }
    end
    
    def initialize(klass, key_persister, entry_persister)
      @base_class = klass
      @key_persister = key_persister
      @entry_persister = entry_persister
    end
    
  end
end