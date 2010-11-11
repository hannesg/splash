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
class Array
  
  module WithKnowledgeOfEntries
    
    def kind_of?(other)
      if other < Array::WithKnowledgeOfEntries
        return true if self.class.entry_class <= other.entry_class
        return self.all? do |entry| entry.kind_of? other.entry_class end
      end
      super
    end
    
    module ClassMethods
    
      attr_reader :entry_class
    
      def persister
        Array::Persister.new(self,self.entry_class.persister)
      end
    
    end
    
  end
  
  def self.of(klass)
    Class.new(self){
      
      @entry_class = klass
      
      include WithKnowledgeOfEntries
      extend WithKnowledgeOfEntries::ClassMethods
      
    }
  end
  
end