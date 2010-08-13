if defined? Splash
  raise "Splash included twice!"
end

module Splash
  
  DIR = File.dirname(__FILE__)
  
  autoload :ActsAsCollection,DIR+"/splash/acts_as_collection"
  autoload :ActsAsScope,DIR+"/splash/acts_as_scope"
  autoload :ActsAsScopeRoot,DIR+"/splash/acts_as_scope_root"
  autoload :Annotated,DIR+"/splash/annotated"
  autoload :Scope,DIR+"/splash/scope"
  autoload :Entity,DIR+"/splash/entity"
  autoload :Validates,DIR+"/splash/validates"
  autoload :Saveable,DIR+"/splash/saveable"
  autoload :HasAttributes,DIR+"/splash/has_attributes"
  autoload :NameSpace,DIR+"/splash/namespace"
  autoload :Query,DIR+"/splash/query"
  autoload :View,DIR+"/splash/view"
  autoload :Application,DIR+"/splash/application"
  autoload :Persister, DIR+"/splash/persister"
  autoload :Lazy,DIR+"/splash/lazy"
  autoload :QueryInterface,DIR+"/splash/query_interface"
  autoload :Embed,DIR+"/splash/embed"
  autoload :UseDefaultAttributes,DIR+"/splash/use_default_attributes"
  autoload :Document,DIR+"/splash/document"
  autoload :Collection,DIR+"/splash/collection"
  autoload :ScopeDelegator,DIR+"/splash/scope_delegator"
  autoload :Exportable,DIR+"/splash/exportable"
  autoload :Attribute, DIR+"/splash/attribute"
  autoload :HasConstraint, DIR+"/splash/has_constraint"
  autoload :Constraint, DIR+"/splash/constraint"
  autoload :AttributedStruct, DIR+"/splash/attributed_struct"
  autoload :Password, DIR+"/splash/password"
  
end
Dir[Splash::DIR+"/splash/standart_extensions/*.rb"].each do |path|
  require path
end
