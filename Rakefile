require 'rubygems'
require 'rake'
require 'rake/gempackagetask'
gem 'rspec'
require 'spec/version'
require 'spec/rake/spectask'
require 'spec/ruby'

task :default => [:spec] 

#spec = Gem::Specification.load "splash.gemspec"
#Rake::GemPackageTask.new(spec) do |pkg|
#  pkg.need_zip = true
#  pkg.need_tar = true
#end

Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
end