#!/usr/bin/ruby

require "#{File.expand_path(File.dirname(__FILE__))}/lp.rb"

lp = Lineprinter.new

###
lp.printline
lp.h1("test")
