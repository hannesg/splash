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
require File.expand_path(File.join(File.dirname(__FILE__),"../helper"))

describe Splash::Annotated do
  
  it "should work for modules" do
    
    module NameAnnotations
      
      include Splash::Annotated
      
      extend Concerned
      
      module ClassMethods
      
        def named(fn,name)
          @named||={}
          @named[fn]=name
        end
        
        def name(fn)
          return @named[fn] rescue nil
        end
        
        define_annotation :named
      end
      
    end
    
    class ClassWithSimpleAnnotations
      
      include NameAnnotations
      
      named "Nice Function!"
      def nice
        return 42
      end
      
    end
    
    ClassWithSimpleAnnotations.name(:nice).should == "Nice Function!"
    
  end
  
  it "should work for classes" do
    
    class AnnotatedParent
      
      include Splash::Annotated
      
      class << self
        
        def named(fn,name)
          @named||={}
          @named[fn]=name
        end
        
        def name(fn)
          return @named[fn] rescue nil
        end
        
        define_annotation :named
        
      end
      
    end
    
    class Child < AnnotatedParent
      
      include NameAnnotations
      
      named "Nice Function!"
      def nice
        return 42
      end
      
    end
    
    Child.name(:nice).should == "Nice Function!"
    
  end
  
end
