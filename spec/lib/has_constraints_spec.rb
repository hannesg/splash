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

describe Splash::HasConstraints do
  
  class ObjectWithConstraints
    
    include Splash::HasConstraints
    
    include Splash::Constraint::SimpleInterface
    
    attr_accessor :foo
    
    attr_accessor :baz
    
    validate_not_nil
    attr_accessor :many_baz
    
    validate :foo_may_not_be_bar
    
    protected
      def foo_may_not_be_bar(result)
        if foo == "bar"
          result['foo'].errors << "Foo may not be bar!"
        end
      end
  end
  
  it "should look cool and work" do
    
    o = ObjectWithConstraints.new
    
    o.foo = "bar"
    
    o.validate.should be_error
    
  end
  
  it "should support validating nested attributes" do
    
    ObjectWithConstraints.constraints << Splash::Constraint::Valid.new('baz')
    
    o = ObjectWithConstraints.new
    
    o.baz = ObjectWithConstraints.new
    
    o.baz.foo = "bar"
    
    result = o.validate
    
    result.should be_error
    
    result['baz']['foo'].errors.should_not be_empty
    
  end
  
  it "should support validating nested attribute sets" do
    
    ObjectWithConstraints.constraints << Splash::Constraint::Valid.new('many_baz')
    
    o = ObjectWithConstraints.new
    
    o.many_baz = []
    
    5.times do
      b = ObjectWithConstraints.new
      b.foo = "bar"
      o.many_baz << b
    end
    
    result = o.validate
    
    result.should be_error
    
    result['many_baz'].should_not be_empty
    
  end
  
  it "should support inheritance" do
    
    class ChildObjectWithConstraints < ObjectWithConstraints
      
      attr_accessor :age
      
      validate do |object, result|
        if object.age.kind_of? Numeric and object.age < 18
          result['age'].errors << 'Du musst volljährig sein!'
        end
      end
      
      validate('age') do |age|
        if age.kind_of? Numeric and age > 50
          errors << 'Altersdiskriminierung!'
        end
        
      end
      
    end
    
    o = ChildObjectWithConstraints.new
    
    o.baz = ObjectWithConstraints.new
    
    o.baz.foo = "bar"
    
    o.age = 17
    
    result = o.validate
    
    result.should be_error
    
    result['age'].errors.should_not be_empty
    
    o.age = 51
    
    result = o.validate
    
    result.should be_error
    
    result['age'].errors.should_not be_empty
    
  end
  
  
end