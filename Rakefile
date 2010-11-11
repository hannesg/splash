require 'rubygems'
require 'bundler'
Bundler.setup(:development, :default)
Bundler.require(:development, :default)
require 'rake'
require 'rake/gempackagetask'
require 'rspec/core/rake_task'

task :default => [:spec] 

spec = Gem::Specification.load "splash.gemspec"
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = ["-c", "-f progress", "-r ./spec/helper.rb"]
  t.pattern = 'spec/**/*_spec.rb'
end
