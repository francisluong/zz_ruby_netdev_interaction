#!/usr/bin/env ruby

$: << File.expand_path(File.dirname(__FILE__)) 

class Lineprinter
  attr_accessor :number
  def initialize
    @number = 1
  end
  def printline
    puts "\n==========="
    puts "=== #{@number.to_s.rjust(3, '0')} ==="
    puts "==========="
    @number = @number + 1
  end

  def h1(headline)
    puts "\n============================="
    puts "= #{headline.upcase}"
    puts "============================="
  end
end


