#!/usr/bin/env ruby
require "net/netconf"
require "userpass"
require "#{File.expand_path(File.dirname(__FILE__))}/lp.rb"
require "pry"

if ARGV.length < 2 then
    puts "Usage: #{$0} <path_to_userpass_file> <router_address>"
    exit
end
auth = Userpass.new(ARGV[0])
puts "User: #{auth.user}"
host = ARGV[1]
lp = Lineprinter.new

commands_list = ['show version', "show chassis hardware"]
login_cred = { :target => host, :username => auth.user, :password => auth.passwd }
Netconf::SSH.new(login_cred) do |ssh|

    #ssh via event loop
    lp.h1 "get-software-information"
    swinfo = ssh.rpc.get_software_information
    puts "Model: #{swinfo.xpath('//product-name').text}"
    puts "Junos Kernel: #{swinfo.xpath('//package-information[name="jkernel"]/comment').text}"
    puts swinfo.class
    #binding.pry
    puts "Full XML:\n#{swinfo.to_xml(:indent => 4, :indent_text => " ")}"
end

