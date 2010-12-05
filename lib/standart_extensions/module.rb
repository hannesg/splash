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
class Module
  
  def persister
    return self
  end
  
  def to_saveable(obj)
    return obj
  end
  
  def from_saveable(obj)
    return obj
  end
  
  def named?
    !anonymous?
  end
  
  def define_annotation(name)
    self.class_eval <<-DEF,__FILE__, __LINE__
alias_method #{(name.to_s+"!").to_sym.inspect}, #{name.inspect}
def #{name.to_s}(*args,&block)
  if args.any? and args.first.kind_of? Symbol
    return #{name.to_s}!(*args,&block)
  end
  @annotations ||= []
  @annotations << [#{(name.to_s+"!").to_sym.inspect},args,block]
end
DEF
end

  def merged_inheritable_attr(name,default=[],&block)
    if block_given?
      merger = lambda &block
    else
      merger = lambda{|a,b| a if b.nil?; a + b }
    end
    
    self.instance_eval do
      
      @merged_inheritable_attr_info ||={}
      
      @merged_inheritable_attr_info[name] = {:default=>default,:merger => merger }
      
      def self.merged_inheritable_attr_info(name)
        if @merged_inheritable_attr_info && @merged_inheritable_attr_info.key?(name)
          return @merged_inheritable_attr_info[name]
        end
        superclass.merged_inheritable_attr_info(name) if superclass.respond_to?(:merged_inheritable_attr_info)
      end
      
    end
    
    
    
    self.instance_eval <<-DEF,__FILE__, __LINE__
def #{name.to_s}
  @#{name.to_s} ||= merged_inheritable_attr_info(#{name.inspect})[:default].dup
end
def #{name.to_s}=(v)
  @#{name.to_s}=v
end
def all_#{name.to_s}
  unless superclass.respond_to? :all_#{name.to_s}
    return #{name.to_s}
  end
  merged_inheritable_attr_info(#{name.inspect})[:merger].call(#{name.to_s},superclass.all_#{name.to_s})
end
def each_#{name.to_s}(&block)
  c=self
  begin
    c.#{name.to_s}.each &block
    c=c.superclass
  end while(c.respond_to? #{name.to_sym.inspect})
end

DEF
  end
  
  def autoload_all(base)
    Dir[File.join(base,'*.rb')].each do |file|
      path = file[base.size..-4].split('/')
      path.shift if path.first == ''
      path.map! do |part|
        part.gsub(/(^|_)([a-z])/){
          $2.upcase
        }
      end
      autoload path.join, file
    end
  end
  
end
