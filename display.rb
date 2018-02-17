require 'color'

class Display
  attr_reader :colors
  
  def initialize(rows, columns)
    @rows = rows
    @colors = Array.new(rows * columns) { ::Color::RGB.new rand, rand, rand, 1.0 }
  end
  
  def [](r,c)
    @colors[c * @rows + r]
  end
  
  def self.open(interface)
    display = new interface.rows, interface.columns
    interface.open do
      yield display
      display.colors
    end
  end
end