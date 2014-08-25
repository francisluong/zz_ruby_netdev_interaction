#!/usr/bin/env ruby
require "netdev/ssh"
require "userpass"
require "optparse"

options = {:port => "22"}

parser = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} <path_to_userpass_file> <target_ssh_address> [options]"

  opts.on("--port port", "SSH Port (default = '22')") do |port|
    options[:port] = port
  end
end
parser.parse!

#non options remain in ARGV after the parse
path_to_userpass = ARGV[0]
host = ARGV[1]
port = options[:port]

#need to make sure they are set... otherwise dump help and exit
unless (path_to_userpass && host)
  print parser.help
  exit
end

#parse userpass file
auth = Userpass.new(path_to_userpass)
puts "User: #{auth.user}, host: #{host}, port: #{port}"


ssh = NetDev::SSH.new(user: auth.user, passwd: auth.passwd)
ssh.prompt_re = /^.*\$/
ssh.connect(host, port: port)
ssh.send("date")
print ssh.send("ls")
ssh.sendline("env")
ssh.timeout_sec = 3
ssh.wait_for_regex(/TCLLIBPATH/)
puts
ssh.wait_for_regex(/RUBY_VERSION/)
puts
