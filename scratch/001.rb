#!/usr/bin/ruby

require "#{File.expand_path(File.dirname(__FILE__))}/lp.rb"

lp = Lineprinter.new

###
lp.h1("String Basics")
string = "My first string"
print "bob"
puts "Length of #{string} = #{string.length}"
puts "Number of 'i': #{string.count 'i'}"
length = string.length
puts length.next
puts 'length #{length}... so literal!'

lp.h1 "Multiline strings"
long_string = <<FX
This is a multiline string
It has multiple lines
FX
puts long_string

lp.h1 "Slice"
puts string.slice(3,5)
puts string.slice(3..7)
puts string[3..7]
puts string.inspect

lp.h1 "hash to string by << append"
hash = { "Francis" => "Luong", "Copper" => "Kitty", "Ellie" => "Poochness" }
string = ""
hash.each { |k,v| string << "#{k} is a #{v}\n" }
puts string
puts hash.keys.join("\n") + "\n"

lp.h1 "subst"
puts "2 follows #{2 - 1}"

lp.h1 "printf style"
template = "Oceana has always been at war with %s."
puts template % "Eurasia"
puts template % "France"
