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
  
  class Constraint::Result < Hash
    
    include Splash::DotNotation
    
    attr_reader :errors, :base
    
    def initialize(base,path = [] )
      @errors = []
      @base = base
      @path = path
      super() do |hsh,key|
        hsh[key] = Constraint::Result.new(@base,@path + [key])
      end
    end
    
    def _(*args,&block)
      
      if @path.any?
        path = @path.select{|x| !x.kind_of? Numeric }.map &:to_sym
        return ( @base._(:attribute,*path) | @base._ ).errors(*args,{:attribute => @base._.attribute(*path)},&block) 
      else
        return @base._.errors(*args,&block) 
      end
    end
    
    def key?(k)
      # we pretend to have any key, because
      # we will create any key on access
      true
    end
    
    def valid?
      !errors.any? and self.all?{|k,v| v.valid?}
    end
    
    def error?
      !valid?
    end
    
    def <<(other)
      if other.kind_of? Constraint::Result
        self.errors.concat other.errors
        other.each do |key,value|
          self[key] << value
        end
        return self
      else
        self.errors << other
        return self
      end
    end
    
    def inspect
      result = 'Result('
      result << super if self.any?
      result << self.errors.inspect if errors.any?
      result << ')'
      return result
    end
    
    def to_s
      m = ''
      self.errors.each do |e|
        m << "\t#{e}\n"
      end
      self.each do |k,errors|
        m << "\t" + k.to_s + ":\n"
        m << errors.to_s.gsub(/^/,"\t")
      end
      return m
    end
    
  end
  
  
end
