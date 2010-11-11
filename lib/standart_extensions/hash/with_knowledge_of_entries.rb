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
  module WithKnowledgeOfEntries
    
    def kind_of?(other)
      if other < Hash::WithKnowledgeOfEntries
        return true if self.class.entry_class <= other.entry_class and self.class.key_class <= other.key_class
        return self.all? do |key,entry| key.kind_of? other.key_class and entry.kind_of? other.entry_class end
      end
      super
    end
    
    module ClassMethods
    
      attr_reader :key_class, :entry_class
    
      def persister
        Hash::Persister.new(self,self.key_class.persister,self.entry_class.persister)
      end
    
    end
    
  end
  
  def self.of(key_klass, entry_klass)
    Class.new(self){
      
      @key_class = key_klass
      @entry_class = entry_klass
      
      include WithKnowledgeOfEntries
      extend WithKnowledgeOfEntries::ClassMethods
      
    }
  end
end