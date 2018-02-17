require_relative 'layer'
require_relative 'palette'

module Layer
  class Ctx
    attr_accessor :intensity
    
    def initialize(num_layers, rows:, columns:, palette:)
      #palettes = ->(_) { palettes } if Palette === palettes
      
      @layers =
        Array.new(num_layers) do |i|
          Layer.new rows: rows, columns: columns, palette: palette
        end
      @layers.freeze
    end
    
    def [](index)
      @layers[index]
    end
    
    def each(&block)
      @layers.each &block
    end
    
    def render(buffer = nil, intensity: 1.0)
      # Clear the buffer
      buffer.each { |c| c.r = c.g = c.b = 0 } if buffer
      # Render from the bottom up
      @layers.reduce(buffer) do |background, layer|
        layer.to_color! background, intensity: intensity
      end
    end
  end
end