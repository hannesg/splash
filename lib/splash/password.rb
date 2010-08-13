require 'digest/sha1'
require 'securerandom'

class Splash::Password
  
  include Splash::Embed
  
  DIGESTER = Digest::SHA1
  
  def_attribute( 'salt' )
  
  def_attribute( 'hash' )
  
  def matches?(string)
    DIGESTER.hexdigest("#{string}#{self.salt}") == self.hash
  end
  
  def initialize(str_or_args={})
    if str_or_args.kind_of? String
      slt = SecureRandom.hex
      hash = DIGESTER.hexdigest("#{str_or_args}#{slt}")
      super({'salt'=>slt,'hash'=>hash})
    elsif str_or_args.kind_of? Hash
      super(str_or_args)
    else
      super({})
    end
  end
  
  
end