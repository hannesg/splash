Gem::Specification.new do |s|
  s.name = %q{splash}
  s.version = "0.0.1.beta"
  s.date = %q{2010-10-11}
  s.authors = ["HannesG"]
  s.email = %q{hannes.georg@googlemail.com}
  s.summary = %q{Be Splashed!}
  s.homepage = %q{http://github.com/hannesg/splash}
  s.description = %q{Splashes Mongo}
  
  s.require_paths = ["lib"]
  
  s.files = Dir.glob("lib/**/**/*") + ["Rakefile", "Gemfile","splash.gemspec"]
  s.add_dependency "mongo", ">= 1.2"
  s.add_dependency "facets"
  s.add_dependency "cautious"
  
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rake'
end
