# frozen_string_literal: true

require 'forwardable'

module MIDIVisualizer
  class Visualizer
    # Background
    #
    # The Visualizer background wraps a Layer and adds some simple effects to
    # it. Calling #update! will write to the underlying layer.
    class Background
      extend Forwardable

      attr_accessor :params

      def_delegators :@layer, :intensity, :intensity=, :each, :num_states,
                     :width, :height

      DEFAULT_PARAMS = {
        mean:      0.5,
        amplitude: 0.0,
        f:         0.0,
        noise:     0.0,
        spread:    1.0
      }.freeze

      def initialize(layer, params = {})
        @params = params.merge!(DEFAULT_PARAMS) { |_, v, _| v }
        @layer  = layer
        @phase  = random_phase

        # Setup layer
        each { |state| state.i = 1.0 }
      end

      def update!(t)
        layer_height_coeff = 1.0 / height

        each.with_index do |state, i|
          y_norm  = @layer.position(i)[1] * layer_height_coeff
          palette = @params[:mean] + (y_norm - 0.5) * @params[:spread]
          phase   = @params[:noise] * @phase[i]

          state.p = palette + osc(t, phase)
        end
      end

      private

      def osc(t, phase)
        @params[:amplitude] * Math.cos(t * 2 * Math::PI * @params[:f] + phase)
      end

      def random_phase
        Array.new(num_states) { rand * 2 * Math::PI }
      end
    end
  end
end
