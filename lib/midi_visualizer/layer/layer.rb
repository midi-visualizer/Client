# frozen_string_literal: true

require 'forwardable'

module MIDIVisualizer
  module Layer
    # Layer
    #
    # The layer is a fundemental building block in the visualizer graphics
    # chain. It holds the state of each pixel in the layer as well as the
    # palette that should be used to render said state.
    class Layer
      extend Forwardable

      attr_accessor :intensity
      attr_reader :states
      
      def_delegators :@context, :rows, :columns, :width, :height

      def initialize(context, palette:)
        @context = context
        
        @row_factor = height / rows
        @col_factor = width / columns
        @states  = Array.new(num_states) { State.new }
        @palette = palette
        @intensity = 1.0
      end
      
      def num_states
        rows * columns
      end

      def [](index)
        @states[index]
      end

      # Change the states
      def each(&block)
        @states.each(&block)
      end

      # If a background is supplied the layer will mix its colors with those of
      # the background, based on the intensity of each pixel.
      #
      # Returns an array of colors. If background is given it will be mutated.
      def to_color!(background, intensity: 1.0)
        if background
          background.each_with_index do |color, index|
            state = @states[index]
            next unless state.i > 0

            color_full = @palette[state.p]
            i = state.i * intensity * @intensity

            color.r = color_full.r * i + color.r * (1 - i)
            color.g = color_full.g * i + color.g * (1 - i)
            color.b = color_full.b * i + color.b * (1 - i)
          end
        else
          to_color intensity: intensity
        end
      end

      def to_color(intensity: 1.0)
        @states.map do |state|
          color_full = @palette[state.p].dup
          i = state.i * intensity * @intensity
          # Mute the color
          color_full.r = color_full.r * i
          color_full.g = color_full.g * i
          color_full.b = color_full.b * i
        end
      end

      # Returns the Euclidean distance between state indecies a and b.
      #
      # Warning: no validity check is performed
      def distance(a, b)
        dx = (a / rows - b / rows) * @col_factor
        dy = (a % rows - b % rows) * @row_factor

        Math.sqrt(dx**2 + dy**2)
      end

      def position(state)
        [
          (state / rows) * @col_factor,
          (state % rows) * @row_factor
        ]
      end
    end
  end
end
