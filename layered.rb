require_relative 'layer'
require_relative 'palette'

class Layered
  def initialize(num_layers, size, palette)
    #palettes = ->(_) { palettes } if Palette === palettes
    
    @layers = Array.new(num_layers) { |i| Layer.new size, palette }.freeze
  end
  
  def [](index)
    @layers[index]
  end
  
  def each(&block)
    @layers.each &block
  end
  
  def render(buffer = nil)
    # Clear the buffer
    buffer.each { |c| c.r = c.g = c.b = 0 } if buffer
    # Render from the bottom up
    @layers.reduce(buffer) { |background, layer| layer.to_color! background }
  end
end