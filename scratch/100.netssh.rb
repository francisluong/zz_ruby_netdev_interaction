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

    #ssh via event loop
    lp.h1 "RPC"
    rpc = "<rpc message-id=\"1001\"><get-software-information/></rpc>"
    puts rpc
    MSG_END = "]]>]]>"
    MSG_END_RE = /\]\]>\]\]>[\r\n]*$/
    MSG_CLOSE_SESSION = '<rpc><close-session/></rpc>'
    done = false
    wait_sec = 0.01
    channel = ssh.open_channel do |ch|
        ch.exec "netconf" do |netconf, success|
            output = ""
            output << "Start\n"
            if success
                puts "NETCONF subsystem successfully started"
            else
                puts "NETCONF subsystem could not be started"
            end
            netconf.on_data do |c, data|
                #if we get the end of message marker, hello message has been received.
                # now send crude rpc and disconnect
                output << data
                #puts data
                if data =~ MSG_END_RE && rpc != "" then
                    output << rpc
                    netconf.send_data rpc do |x, success|
                        raise "could not execute command" unless success
                    end
                    netconf.send_data MSG_CLOSE_SESSION
                    rpc = ""
                end
            end

            netconf.on_extended_data do |c, type, data|
                puts "ERROR: #{type} #{data}"
            end

            netconf.on_close {
                puts "Closing NETCONF channel!"
                done = true
                output << "\nFinish"
            }

        end
    end

    ssh.loop(wait_sec) {not done}
end

lp.h1 "RPC Output"
puts output
