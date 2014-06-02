#!/usr/bin/env ruby
require "net/ssh"
require "~/bin/ruby/auth.rb"

auth = Auth.new("~/bin/.rad")
puts "User: #{auth.user}"
host = "10.155.96.12"

Net::SSH.start(host, auth.user, :password => auth.passwd) do |ssh|
  output = ssh.exec!("show version")
  puts output
  puts "Output Class: #{output.class}"
  output_array = output.split("\n")
  software_suite = output_array.grep("/.*Base .*uite.*/")
  o_match = output.match /(JUNOS\sBase\sOS\sboot\s\[[\d\.\w]+\])/
  o_match = output.match /(.*Base .*uite.*)/
  puts "\n#Grep out: #{software_suite}"
  puts "\n#Match out: #{o_match}"
end
