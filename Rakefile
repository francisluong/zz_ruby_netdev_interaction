# -*- mode: ruby -*-
# vi: set ft=ruby :


task :default => 'test'

namespace :test do
  specroot = "./spec"
  specfolders = Dir.glob("#{specroot}/*").select { |dir| File.directory?(dir) }
  specfolders.each do |library|
    filename = File.basename(library)
    taskname = filename.to_sym
    desc "Run tests for suite #{taskname}"
    task taskname do
      Dir.glob("#{specroot}/#{taskname}/**/*spec*").each do |specfile|
        if specfile =~ /.*vendor\/bundle.*/
        else
          output = sh "rspec -fd -c #{specfile}"
        end
      end
    end
  end
end

desc "Run ALL Tests"
task :test do
  Rake::Task.tasks.each do |task|
    if task.to_s.start_with? "test:"
      Rake::Task[task].invoke
    end
  end
end

desc "Clean Up"
task :clean do
  sh "rm -rf coverage"
  sh "rm Gemfile.lock"
  sh "rm *.gem"
end

desc "Build"
task "build" do
  begin
    gem "bundler"
  rescue Gem::LoadError
    system "gem install bundler"
  end

end
