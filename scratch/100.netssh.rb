#!/usr/bin/env ruby
require "net/ssh"
require "~/bin/ruby/auth.rb"
require "./lp.rb"

if ARGV.length < 2 then
    puts "Usage: #{$0} <path_to_userpass_file> <router_address>"
    exit
end
auth = Auth.new(ARGV[0])
puts "User: #{auth.user}"
host = ARGV[1]
lp = Lineprinter.new

commands_list = ['show version', "show chassis hardware"]
Net::SSH.start(host, auth.user, :password => auth.passwd) do |ssh|

    commands_list.each { |command|
        output = ssh.exec!(command)
        lp.h1 command
        puts "Output Class: #{output.class}"
        puts output
    }

    lp.h1 "Extracting Text"
    output = ssh.exec!("show version")
    puts output
    output_array = output.split("\n")
    expressions = [/(.*JUNOS\sSoftware.*)/, /.*/]
    expressions.each { |expr| 
        o_expr_match = output_array.select { |line|
            line =~ expr
        }
        o_match = output.match expr
        puts "\nLines Matching #{expr} (via select):\n  #{o_expr_match}"
        puts "\nLines Matching #{expr} (via match):\n  #{o_match}"
    }
end
