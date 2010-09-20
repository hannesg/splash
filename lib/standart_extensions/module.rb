class Module
  
  def persister
    @persister ||= Splash::Persister
  end
  
  def persister=(p)
    @persister=p
  end
  
  def named?
    to_s[0..1]!="#<"
  end
  
  def define_annotation(name)
    self.class_eval <<-DEF,__FILE__, __LINE__
alias_method #{(name.to_s+"!").to_sym.inspect}, #{name.inspect}
def #{name.to_s}(*args,&block)
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
def each_#{name.to_s}
  c=self
  begin
    yield(c.#{name.to_s})
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