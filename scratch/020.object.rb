#!/usr/bin/env ruby
obj = Object.new

def obj.talk
  puts "I am an object."
  puts "(Do you object?)"
end

def obj.c2f(c)
  return c * 9.0 / 5.0 + 32
end

def obj.c2ftoo c
  c * 9.0 / 5.0 + 32
  return "bob"
end

puts obj.c2f(100)
puts obj.c2ftoo 99
