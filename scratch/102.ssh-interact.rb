#!/usr/bin/env ruby
require "ssh-interact"
require "userpass"

if ARGV.length < 2 then
    puts "Usage: #{$0} <path_to_userpass_file> <target_ssh_address>"
    exit
end


    auth = Userpass.new(ARGV[0])
    puts "User: #{auth.user}"
    host = ARGV[1]

    ssh = NetDev::SSH.new(auth.user, auth.passwd)
    ssh.prompt_re = /^.*\$/
    ssh.connect(host)
    print ssh.send("env")
