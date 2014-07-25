#!/usr/bin/env ruby
require "userpass"
require "sloe/junos"

auth = Userpass.new("~/bin/.rad")
host = "10.155.96.12"
login = {:target => host, :username => auth.user, :password => auth.passwd}
command = ARGV.join " "
command_xml = "#{command} | display xml rpc"
puts  "==="

ssh = Net::SSH.start(host, auth.user, :password => auth.passwd)
output = ssh.exec!( command_xml )
parse = Nokogiri::XML(output)
puts parse, "---"
puts "","  #{command}  ==>  #{parse.xpath('//rpc').children[1].name}",""
