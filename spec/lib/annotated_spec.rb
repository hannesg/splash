require File.join(File.dirname(__FILE__),"../helper")

describe Splash::Annotated do
  
  it "should work for modules" do
    
    module NameAnnotations
      
      include Splash::Annotated
      
      class << self
        def included(base)
          base.extend(ClassMethods)
          super
        end
      end
      
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