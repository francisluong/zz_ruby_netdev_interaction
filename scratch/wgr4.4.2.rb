#!/usr/bin/env ruby

require "#{File.expand_path(File.dirname(__FILE__))}/lp.rb"
lp = Lineprinter.new

###
lp.printline

# there aren't clear guidelines on when to mix modules and when to
# subclass.  But you only get to subclass from one class.
# aim for clarity.

#example from the book
module SelfPropelling
  def itGoes
  end

end

class Vehicle
  include SelfPropelling
end

# Truck logically descends from Vehicle
class Truck < Vehicle
end



# Also you can use a module as a namespace

module Tools
  class Hammer
  end
end

h = Tools::Hammer.new()
