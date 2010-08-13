module Splash::Exportable
  
  RAW_TYPES=[String,NilClass,Numeric,FalseClass,TrueClass]
  
  class << self
    def included(base)
      base.extend(ClassMethods)
    end
    
    def export(v)
      if v.respond_to? :export
        return v.export
      elsif RAW_TYPES.any? do |type| v.kind_of? type end
        return v
      elsif v.kind_of? Array
        return v.inject([]){ |memo,value| memo << Splash::Exportable.export(value); memo }
      elsif v.kind_of? Hash
        return v.inject({}){ |memo,(key,value)| memo[Splash::Exportable.export(key)] = Splash::Exportable.export(value); memo }
      end
      return "<unexportable[#{v.inspect}]>"
    end
  end
  
  module ClassMethods
    
    def method_added(name)
      if @exportable
        export_options[:methods] << name
      end
    end
    
    def exportable(*args)
      if args.size > 0
        export_options[:methods] += args
      else
        @exportable = false
      end
    end
    
    def export_options
      @export_options ||= {:methods=>[]}
    end
    
  end
  
  def export
    result={}
    self.class.export_options[:methods].each do |key|
      value = self.send(key)
      result[key]=Splash::Exportable.export(value)
    end
    return result
  end
  
  def export_method(name)
    Splash::Exportable.export(self.send(name))
  end
end