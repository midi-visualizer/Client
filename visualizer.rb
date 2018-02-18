require 'color'

require_relative 'layer/ctx'
require_relative 'layer/palette'

require_relative 'visualizer/background'

class Visualizer
  attr_reader :background
  
  def initialize(interface, palette_bg, palette_fg = palette_bg)
    @layers = Layer::Ctx.new 2, rows: interface.rows,
                                columns: interface.columns,
                                palettes: [palette_bg, palette_fg]
    @buffer = Array.new(interface.rows * interface.columns) {
      Color::RGB.new rand, rand, rand, 1.0 }
    @interface  = interface
    @background = Background.new @layers[0]
  end
    
  def foreground
    @layers[1]
  end
  
  def num_states
    @interface.rows * @interface.columns
  end
  
  def run
    @interface.open do
      t = Time.now.to_f
      
      yield t, background, foreground
      
      background.update!(t)
      
      @layers.render(@buffer)
      @buffer
    end
  end
end