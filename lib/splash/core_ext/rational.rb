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
require 'facets/na'
require 'facets/object/dup'
class Rational


  def self.to_saveable(x)
    begin
      rat = Rational(x)
      return {'numerator' => rat.numerator, 'denominator' => rat.denominator }
    rescue TypeError, ArgumentError
    end
    return nil
  end

  def self.from_saveable(x)
    if x.kind_of? Hash and x['numerator'].kind_of? Numeric and x['denominator'].kind_of? Numeric
      return Rational(x['numerator'], x['denominator'])
    end
    begin
      # at least give it a chance
      return Rational(x)
    rescue TypeError, ArgumentError
      return nil
    end
  end

end
