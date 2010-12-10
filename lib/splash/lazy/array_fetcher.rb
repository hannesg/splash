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
module Splash
module Lazy
  class ArrayFetcher < Fetcher
    
    def [](*args)
      start, length = args
      if start.kind_of? Range
        length = start.count
        start = start.begin
      end
      if length.nil?
        length = 1
      end
      docs = @collection.find_without_lazy({'_id'=>@id},{:fields=>field_slices({'_id'=>1,@path => {'$slice'=>[start,length]}})})
      if docs.has_next?
        return self.get_result(docs.next_document)
      end
      return ::NA
    end
    
  end
end
end