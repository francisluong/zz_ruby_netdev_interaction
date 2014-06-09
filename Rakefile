
task :default do
  Dir.glob("**/*spec.rb*").each do |specfile|
    if specfile =~ /.*vendor\/bundle.*/
    else
      output = sh "rspec -fd -c #{specfile}"
    end
  end
end
