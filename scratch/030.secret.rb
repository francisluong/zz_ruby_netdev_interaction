#!/usr/bin/env ruby

require 'highline/import'

secret = ask("What's your secret? "){|a| a.echo = false}

puts "I'm telling your secret: #{secret}"
