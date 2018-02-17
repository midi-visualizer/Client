require_relative 'layer'

class Layered
  def initialize(num_layers, size, palettes)
    palettes = ->(_) { palettes } if palettes === Palette
    @layers = Array.new(num_layers) { |i| Layer.new size, palettes[i] }.freeze
  end
  
  def [](index)
    @layer[index]
  end
  
  def each(&block)
    @layers.each &block
  end
  
  def flatten
    # Render from the bottom up
    @layers.reduce(nil) { |background, layer| layer.to_color! background }
  end
end