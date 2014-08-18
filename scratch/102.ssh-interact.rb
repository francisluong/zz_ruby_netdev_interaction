#!/usr/bin/env ruby
require "netdev/ssh"
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
ssh.send("date")
print ssh.send("ls")
ssh.sendline("env")
ssh.timeout_sec = 3
ssh.wait_for_regex(/TCLLIBPATH/)
puts
ssh.wait_for_regex(/RUBY_VERSION/)
puts
