require_relative 'state'

module Layer
  class Layer
    def initialize(size, palette)
      @rows, @columns =
        if Array === size
          size[0..1]
        else
          [size, 1]
        end
      
      @states  = Array.new(@rows * @columns) { State.new }
      @palette = palette
    end
    
    def [](index)
      @states[index]
    end
    
    def num_states
      @rows * @columns
    end
    
    # If a background is supplied the layer will mix its colors with those of the
    # background, based on the intensity of each pixel.
    #
    # Returns an array of colors. If background is given it will be mutated.
    def to_color!(background = nil)
      if background
        background.each_with_index do |color, index|
          state = @states[index]
          next unless state.i > 0
          
          color_full = @palette[state.p]
          
          color.r = color_full.r * state.i + color.r * (1 - state.i)
          color.g = color_full.g * state.i + color.g * (1 - state.i)
          color.b = color_full.b * state.i + color.b * (1 - state.i)
        end
      else
        @states.map do |state|
          color_full = @palette[state.p].dup
          # Mute the color
          color_full.r = color_full.r * state.i
          color_full.g = color_full.g * state.i
          color_full.b = color_full.b * state.i
        end
      end
    end
    
    def to_color
      to_color!
    end
    
    # Returns the Euclidean distance between state indecies a and b.
    #
    # Warning: no validity check is performed
    def distance(a, b)
      dx = (a / @columns) - (b / @columns)
      dy = (a % @columns) - (b % @columns)
        
      Math.sqrt(dx**2 + dy**2)
    end
  end
end