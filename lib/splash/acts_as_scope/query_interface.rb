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
  
  module ActsAsScope::QueryInterface
    
    %w(eager lazy limit conditions fieldmode with_id extend_scoped sort writeback where including).each do |fct|
      class_eval <<-CODE, __FILE__,__LINE__
def #{fct}(*args,&block)
  query(query_#{fct}(*args,&block))
end
def #{fct}!(*args,&block)
  query!(query_#{fct}(*args,&block))
end
protected :#{fct}!
CODE
    end
    
    protected
    
      def query_eager(*field)
        fields=field.flatten.inject({}){|hsh,key|
          hsh[key.to_s]=1
          hsh
        }
        return {:fields=>fields}
      end
      
      def query_lazy(*field)
        fields=field.flatten.inject({}){|hsh,key|
          hsh[key.to_s]=0
          hsh
        }
        return {:fields=>fields}
      end
      
      def query_including(*fields)
        return {:including=>fields}
      end
      
      def query_limit(limit)
        return {:limit=>limit}
      end
      
      def query_conditions(conditions)
        return {:query=>conditions}
      end
      
      def query_default_attributes(values)
        
      end
      
      def query_with_id(*args)
        ids=args.flatten.map do |id|
          if id.kind_of? BSON::ObjectId
            id
          elsif id.kind_of? Hash and id['$oid']
            BSON::ObjectId(id['$oid'])
          else
            BSON::ObjectId(id)
          end
        end
        if ids.size == 1
          return {:query=>{"_id"=>ids.first}}
        else
          return {:query=>{"_id"=>{"$in"=>ids}}}
        end
      end
      
      def query_fieldmode(type)
        return {:fieldmode=>type}
      end
      
      def query_sort(*args)
        result=[]
        args.each do |arg|
          if arg.kind_of? String
            result << [arg,'ascending']
          elsif arg.kind_of? Hash
            result += arg.to_a
          end
        end
        return {:sort=>result}
      end
      
      def query_extend_scoped(*modules,&block)
        if block_given?
          m=Module.new
          m.class_eval &block
          modules << m
        end
        
        modules.each do |mod|
          self.extend(mod)
        end
        
        return {:extend_scoped => modules}
      end
      
      def query_where(conditions)
        return (query_conditions(conditions) + query_writeback(conditions))
      end
      
      def query_writeback(args=nil,&block)
        if args
          return {:writeback=>Splash::Writeback.cast(args)}
        elsif block_given?
          return {:writeback=>Splash::Writeback.cast(block)}
        end
      end
  end
end
