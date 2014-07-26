#!/usr/bin/ruby

require "#{File.expand_path(File.dirname(__FILE__))}/lp.rb"

lp = Lineprinter.new

###
lp.printline
lp.h1("test")


puts "class methods are essentially singleton methods for class objects"


lp.h1("Listing 5.2")

class Person
    attr_accessor :first_name, :middle_name, :last_name

    def whole_name
        n = first_name + " "
        n << "#{middle_name} " if middle_name
        n << last_name
    end

    def printname
        puts "#{self} Whole Name: #{self.whole_name}"
    end

end

watson = Person.new
watson.first_name = "John"
watson.last_name = "Watson"
watson.printname

watson.middle_name = "Hamish"
watson.printname
