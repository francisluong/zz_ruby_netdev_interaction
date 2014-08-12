# -*- mode: ruby -*-
# vi: set ft=ruby :


task :default => 'test'

desc "Run rspec tests (default)"
task :test do
  Dir.glob("**/*spec.rb*").each do |specfile|
    if specfile =~ /.*vendor\/bundle.*/
    else
      output = sh "rspec -fd -c #{specfile}"
    end
  end
end

desc "Clean Up"
task :clean do
    sh "rm -rf coverage"
    sh "rm Gemfile.lock"
end
