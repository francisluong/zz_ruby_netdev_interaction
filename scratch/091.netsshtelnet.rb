#!/usr/bin/env ruby
require "net/ssh"
require "net/ssh/telnet"
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

commands_list = ['ls -l github']
ssh = Net::SSH.start(host, auth.user, :password => auth.passwd)

session = Net::SSH::Telnet.new(
    "Session" => ssh,
    "Prompt" => /^.*\$/
)

commands_list.each do |command|
    puts session.cmd(command)
end
