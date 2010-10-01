module Splash::Document
  
  include Splash::Saveable
  include Splash::HasAttributes
  include Splash::Validates
  
  class << self
    def included(base)
      included_modules.each do |mod|
        mod.included(base)
      end
      
      base.instance_eval do
        include Splash::ActsAsCollection.of(base)
        extend Splash::ActsAsScopeRoot
        
        def included(base)
          Splash::Document.included(base)
          super(base)
        end
      end
    end
    
    def persister
      Splash::Saveable::MultiPersister
    end
  end
  
  def initialize(args={})
    self.attributes.load(args)
  end
  
  def to_saveable
    attributes.raw
  end
end