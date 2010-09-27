class Splash::Scope::Options
  
  OPTION_KEYS=[:fields,:limit,:sort]
  def self.cast(hsh)
    if hsh.kind_of? self
      return hsh
    end
    return self.new(hsh)
  end
  
  def initialize(hsh=nil)
    @options={:selector=>Splash::Matcher.new,:fieldmode=>:exclude,:extend_scoped=>[],:limit=>0,:sort=>[]}
    @options.merge! hsh if hsh
    @options.freeze
  end
  
  def merge(options)
    self.class.new(Splash::Scope::Options.merge_options(@options,options))
  end
  
  def self.merge_options(a,b)
    return {
      :selector => Splash::Matcher.and(a[:selector],b[:selector]),
      :fieldmode => (b[:fieldmode] || a[:fieldmode]),
      :extend_scoped => (a[:extend_scoped] + (b[:extend_scoped] || [])),
      :limit => (b[:limit] || a[:limit]),
      :sort => (a[:sort] + (b[:sort] || [])),
      :write_back => []
    }
  end
  
  def extensions
    @options[:extend_scoped] || []
  end
  
  def to_h
    @options
  end
  
  def selector
    @options[:selector]
  end
  
  def options
    opt=@options.reject{|key,value| !(OPTION_KEYS.include? key)}
    if opt.key? :fields
      if @options[:fieldmode]==:eager
        opt.delete :fields
      else
        fieldmode = (@options[:fieldmode]==:include ? 0 : 1)
        opt[:fields]=opt[:fields].reject{|key,value|
          value == fieldmode
        }
      end
      
    end
    return opt
  end
end