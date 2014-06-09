
task :default do
  Dir.glob("**/*spec.rb*").each do |specfile|
    output = sh "rspec -fd -c #{specfile}"
  end
end
