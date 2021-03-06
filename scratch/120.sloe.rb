#!/usr/bin/env ruby
require "userpass"
require "sloe/junos"

auth = Userpass.new("~/bin/.rad")
puts "User: #{auth.user}"
host = "10.155.96.12"

Sloe::Junos.new(:target => host, :username => auth.user, :password => auth.passwd) do |ssh|
  puts sh_ver = ssh.rpc.get_software_information
  puts sh_ver.xpath('//package-information[name = "jbase"]/comment').text
end
