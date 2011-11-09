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

describe Splash::ActsAsScope::Matcher do
  
  describe "matching" do
    
    it "should work in an easy case" do
      
      a = {
        'foo' => "blue",
        'bar' => 4}
      
      Splash::ActsAsScope::Matcher.cast(
        'foo' => 'blue',
        'bar' => {'$lt' => 5}
      ).matches?(a).should be_true
      
    end
    
    it "should support the $type opperator" do
      
      class IndecisiveKey
        
        include Splash::Document
        
        attribute 'key'
        
      end
      
      docs = []
      
      values = [
        :symbol,
        'str',
        5,
        -10,
        1099511627776,
        -1099511627776,
        0.2342,
        124.124,
        /regexp/,
        [['array']],
        true,
        false,
        nil,
        BSON::Code.new("foo == bar"),
        BSON::Code.new("bar == baz",{'baz'=>1337}),
        BSON::Binary.new([1,3,3,7])
      ]
      
      values.each do |key|
        # single
        docs << IndecisiveKey.new('key'=>key).store!
        # and combined
        values.each do |key2|
          docs << IndecisiveKey.new('key'=>[key,key2]).store!
        end
      end
      
      values.each do |value|
        
        query = Splash::ActsAsScope::Matcher.cast('key'=>{'$type'=>BSON.type(value)})
        
        db_result = IndecisiveKey.conditions(query).to_a
        
        matcher_result = docs.find_all do |other_doc|
          query.matches?(other_doc)
        end
        
        (db_result.map(&:_id) - matcher_result.map(&:_id)).should have(0).items
        (matcher_result.map(&:_id) - db_result.map(&:_id)).should have(0).items
        
      end
      
    end
    
    it "should support the $exists opperator" do
    
      a = {}
      b = {'bar'=>nil}
      
      Splash::ActsAsScope::Matcher.cast(
        'bar' => {'$exists' => false}
      ).matches?(a).should be_true
      
      Splash::ActsAsScope::Matcher.cast(
        'bar' => {'$exists' => true}
      ).matches?(a).should be_false
    
      Splash::ActsAsScope::Matcher.cast(
        'bar' => {'$exists' => false}
      ).matches?(b).should be_false
      
      Splash::ActsAsScope::Matcher.cast(
        'bar' => {'$exists' => true}
      ).matches?(b).should be_true
    
    end
    
  end
  
  describe "merging" do
    
    it "should support merging in a trivial case" do
      
      a = Splash::ActsAsScope::Matcher.cast('name'=>'Max')
      b = Splash::ActsAsScope::Matcher.cast('age'=>20)
      
      a_and_b = a.and b
      
      a_and_b.should == Splash::ActsAsScope::Matcher.cast('name'=>'Max','age'=>20)
      
      a_or_b = a.or b
      
      a_or_b.should == Splash::ActsAsScope::Matcher.cast('$or'=>[{'name'=>'Max'},{'age'=>20}])
      
    end
    
    it "should support merging with overlapping attributes" do
      
      a = Splash::ActsAsScope::Matcher.cast('age'=>{'$lt'=>30})
      b = Splash::ActsAsScope::Matcher.cast('age'=>20)
      
      a_and_b = a.and b
      # TODO: this works but 'age'=>{'$lt'=>30} would be a much better result!
      a_and_b.should == Splash::ActsAsScope::Matcher.cast('age'=>{'$all'=>[20],'$lt'=>30})
      
      a_or_b = a.or b
      
      a_or_b.should == Splash::ActsAsScope::Matcher.cast('$or'=>[{'age'=>{'$lt'=>30}},{'age'=>20}])
      
    end
    
  end
  
end
