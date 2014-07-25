#!/usr/bin/env ruby
require "ssh-interact"
require "userpass"

if ARGV.length < 2 then
    puts "Usage: #{$0} <path_to_userpass_file> <router_address>"
    exit
end


    auth = Userpass.new(ARGV[0])
    puts "User: #{auth.user}"
    host = ARGV[1]

    commands_list = ['show version', "show chassis hardware"]

    ssh = SSH_Interact.new(auth.user, auth.passwd)
    ssh.connect(host)
