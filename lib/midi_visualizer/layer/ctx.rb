# frozen_string_literal: true

module MIDIVisualizer
  module Layer
    # Cxt
    #
    # The Layer Context initializes one or more layers, each with their own
    # palette but all of equal size. The layers can then be accessed and
    # modified independently, but the context takes care of combining them into
    # a single image.
    class Ctx
      attr_accessor :intensity

      def initialize(num_layers, rows:, columns:, palettes:)
        @layers =
          Array.new(num_layers) do |i|
            Layer.new rows: rows, columns: columns, palette: palettes[i]
          end
        @layers.freeze
      end

      def [](index)
        @layers[index]
      end

      def each(&block)
        @layers.each(&block)
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
end
