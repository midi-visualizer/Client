require 'color'

require_relative 'layer/ctx'
require_relative 'layer/palette'

class Visualizer
  def initialize(interface, palette)
    @layers = Layer::Ctx.new 2, [interface.rows, interface.columns], palette
    @buffer = Array.new(interface.rows * interface.columns) { ::Color::RGB.new rand, rand, rand, 1.0 }
    @interface = interface
  end
  
  def background
    @layers[0]
  end
  
  def foreground
    @layers[1]
  end
  
  def run
    @interface.open do
      yield Time.now.to_f, background, foreground
      
      @layers.render(@buffer)
      @buffer
    end
  end
end