# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'rake/clean'
CLEAN.include("coverage", "*.gem")

begin
  require 'rspec/core/rake_task'
  test = RSpec::Core::RakeTask.new(:test)
  test.rspec_opts = ['-fd','-c']
  task :default => :test
rescue LoadError
  # no rspec available
end

desc "Run ALL Tests"
task :test do
  Rake::Task.tasks.each do |task|
    if task.to_s.start_with? "test:"
      Rake::Task[task].invoke
    end
  end
end

desc "Build"
task "build" do
  begin
    gem "bundler"
  rescue Gem::LoadError
    system "gem install bundler"
  end
end
