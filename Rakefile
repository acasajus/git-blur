require 'rubygems'
require 'rspec/core/rake_task'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require 'git-blur/version'

RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = 'spec/*.rb'
      t.rspec_opts = [ '--backtrace', '--color' ]
end

task :build do
    system "gem build git-blur.gemspec"
end

task :install => :build do
    system "gem install git-blur-#{GitBlur::VERSION}"
end


 
task :release => :build do
    system "gem push git-blur-#{GitBlur::VERSION}.gem"
end

task :default  => :spec
