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
  
  class Collection < Mongo::Collection
  
    def initialize(name, namespace)
      @namespace = namespace
      @logger = Namespace::LoggerDelegator.new
      super(name, namespace.db)
    end
    
    def [](name)
      @namespace.collection(self.name+'.'+name)
    end
    
    def _dump(limit)
      Marshal.dump([Splash::Namespace::NAMESPACES.index(@namespace),name])
    end
  
    def self._load(str)
     a = Marshal.load(str)
     return Splash::Namespace::NAMESPACES[a[0]].collection(a[1])
    end
    
    alias_method :find_document, :find_one
    
    def embed(path)
      return EmbeddedCollection.new(path,self)
    end
    
  
  end
  
end
