# frozen_string_literal: true

module MIDIVisualizer
  class Visualizer
    # Background
    #
    # The Visualizer background wraps a Layer and adds some simple effects to
    # it. Calling #update! will write to the underlying layer.
    class Background
      attr_accessor :amplitude, :f
      def initialize(layer, mean: 0.5, amplitude: 0, f: 0.2, noise: 0,
                     spread: 1.0)

        @amplitude = amplitude
        @f = f

        @layer = layer
        @state =
          Array.new(layer.num_states) do |state|
            phase   = rand * noise * 2 * Math::PI
            palette = mean + (layer.position(state)[1] - 0.5) * spread
            p layer.position(state)[1]
            [palette, phase]
          end

        # Setup layer
        layer.each { |state| state.i = 1.0 }
      end

      def intensity=(i)
        @layer.intensity = i
      end

      def osc(t, phase)
        @amplitude * Math.cos(t * 2 * Math::PI * @f + phase)
      end

      def update!(t)
        @state.each_with_index do |(palette, phase), i|
          @layer[i].p = palette + osc(t, phase)
        end
      end
    end
  end
end
