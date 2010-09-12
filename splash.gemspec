Gem::Specification.new do |s|
  s.name = %q{splash}
  s.version = "0.0.1.alpha"
  s.date = %q{2010-09-01}
  s.authors = ["HannesG"]
  s.email = %q{hannes.georg@googlemail.com}
  s.summary = %q{Be Splashed!}
  s.homepage = %q{http://github.com/hannesg/splash}
  s.description = %q{Splashes Mongo}
  
  s.require_paths = ["lib"]
  
  s.files = Dir.glob("{lib,spec}/**/**/*") + ["Rakefile", "Gemfile","splash.gemspec"]
  s.add_dependency "mongo", ">= 1.0"
  
  s.add_development_dependency 'rspec', ">= 1.3"
end
