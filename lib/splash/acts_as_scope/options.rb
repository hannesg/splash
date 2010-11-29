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
module Splash::ActsAsScope
  
  class Options
    
    OPTION_KEYS=[:fields,:limit,:sort, :skip]
    def self.cast(hsh)
      if hsh.kind_of? self
        return hsh
      end
      return self.new(hsh)
    end
    
    def initialize(hsh=nil)
      @options={:query=>nil,:fieldmode=>nil,:extend_scoped=>[],:limit=>nil,:sort=>[],:writeback=>nil,:skip=>nil,:including=>[],:fields=>{}}
      @options.merge! hsh if hsh
      @options.freeze
    end
    
    def merge(options)
      self.class.new(self.class.merge_options(@options,options))
    end
    
    def self.merge_options(a,b)
      return {
        :query => Matcher.and(a[:query],b[:query]),
        :fields => (b[:fields] ? (a[:fields] + b[:fields]) : a[:fields]),
        :fieldmode => (b[:fieldmode] || a[:fieldmode]),
        :extend_scoped => (a[:extend_scoped] + (b[:extend_scoped] || [])),
        :limit => (b[:limit] || a[:limit]),
        :sort => (a[:sort] + (b[:sort] || [])),
        :writeback => Splash::Writeback.merge(a[:writeback],b[:writeback]),
        :skip => (b[:skip] || a[:skip]),
        :including => (a[:including] + (b[:including] || []))
      }
    end
    
    def extensions
      @options[:extend_scoped] || []
    end
    
    def includes
      @options[:including] || []
    end
    
    def fieldmode
      @options[:fieldmode] || :exclude
    end
    
    def fields
      @options[:fields] || {}
    end
    
    def to_h
      @options
    end
    
    def selector
      @options[:query] || Matcher.new
    end
    
    def writeback(to)
      if @options[:writeback]
        @options[:writeback].writeback(to)
      end
      return to
    end
    
    def options
      opt=@options.slice(*OPTION_KEYS)
      if opt.key? :fields
        if @options[:fieldmode]==:all
          opt.delete :fields
        elsif @options[:fieldmode]==:none
          opt[:fields]={}
        else
          fieldmode = (@options[:fieldmode]==:include ? 0 : 1)
          opt[:fields]=opt[:fields].reject{|key,value|
            value == fieldmode
          }
          if opt[:fields].none?
            opt.delete :fields
          end
        end
        
      end
      return opt
    end
  end
end
