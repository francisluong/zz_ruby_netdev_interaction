#!/usr/bin/env ruby

require 'net/netconf'
require '~/bin/ruby/auth.rb'

auth = Auth.new("~/bin/.rad")
puts "User: #{auth.user}"
host = "10.155.96.12"

login = {:target => host, :username => auth.user, :password => auth.passwd}

Netconf::SSH.new ( login ) { |dev|
  inv = dev.rpc.get_chassis_inventory
  description = inv.xpath('chassis/description').text
  serial_number = inv.xpath('chassis/serial-number').text

  puts "#{description}: #{serial_number}"
}
