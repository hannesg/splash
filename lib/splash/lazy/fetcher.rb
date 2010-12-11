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
  class Lazy::Fetcher
    
    def initialize(collection,id,path,slices={})
      @collection, @id = collection, id
      
      real_path = []
      @slices = {}
      fetch_path = []
      DotNotation.parse_path(path).each do |part|
        if part.kind_of? Numeric
          current_path = real_path.join('.')
          part += slices[current_path] if slices.key? current_path
          @slices[current_path] = {'$slice'=>[part,1]}
          fetch_path << 0
        else
          real_path << part
          fetch_path << part
        end
      end
      @path = real_path.join('.')
      @fetch_path = fetch_path.join('.')
    end
    
    def [](*args)
      raise "This method is abstract. Please implement `[]` on #{self.to_s}."
    end
    
    def all
      docs = @collection.find_without_lazy({'_id'=>@id},{:fields=>field_slices({@path => 1})})
      if docs.has_next?
        return self.get_result(docs.next_document)
      end
      return ::NA
    end
protected
    def field_slices(base)
      return base.merge(@slices)
    end
    
    def get_result(doc)
      DotNotation.get(doc,@fetch_path)
    end
    
  end
end