#!/usr/bin/env ruby
require "net/ssh"
require "userpass"
require "#{File.expand_path(File.dirname(__FILE__))}/lp.rb"

if ARGV.length < 2 then
    puts "Usage: #{$0} <path_to_userpass_file> <router_address>"
    exit
end
auth = Userpass.new(ARGV[0])
puts "User: #{auth.user}"
host = ARGV[1]
lp = Lineprinter.new

    commands_list = ['env']
Net::SSH.start(host, auth.user, :password => auth.passwd) do |ssh|

    commands_list.each { |command|
        output = ssh.exec!(command)
        lp.h1 command
        puts "Output Class: #{output.class}"
        puts output
    }

end
