# frozen_string_literal: true

module MIDIVisualizer
  module Layer
    # Grid
    #
    # The grid structure stores the number of rows and columns as well as its
    # width and height. The dimensions are normalized to fit within a 1x1
    # square.
    #
    # Aspect ratio is defined as width/height.
    Grid = Struct.new(:rows, :columns, :width, :height) do
      def initialize(rows, columns, aspect_ratio: 1.0)
        wh = aspect_ratio < 1.0 ? [aspect_ratio , 1.0] : [1.0, 1.0/aspect_ratio]
        super(rows, columns, *wh)
      end
    end
  end
end
