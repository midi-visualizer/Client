# frozen_string_literal: true

module MIDIVisualizer
  module Layer
    # State
    #
    # The Later State class implements a simple two value struct, storing the
    # palette color and intensity of the pixel.
    State = Struct.new(:p, :i) do
      def initialize(p = 0.0, i = 0.0)
        super
      end
    end
  end
end
