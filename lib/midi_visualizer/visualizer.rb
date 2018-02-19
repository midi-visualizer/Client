# frozen_string_literal: true

module MIDIVisualizer
  class Visualizer
    attr_reader :background

    DEFAULT_PARAMS = {
      background: {}
    }.freeze

    def initialize(interface, palette_bg, palette_fg = palette_bg, params: {})
      @params = params.merge!(DEFAULT_PARAMS) { |_, v, _| v }
      @layers = Layer::Ctx.new 2, rows: interface.rows,
                                  columns: interface.columns,
                                  palettes: [palette_bg, palette_fg]

      @buffer =
        Array.new(interface.rows * interface.columns) do
          Color::RGB.new rand, rand, rand, 1.0
        end

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

        yield t, @params

        background.update!(t, params: @params[:background])

        @layers.render(@buffer)
        @buffer
      end
    end
  end
end
