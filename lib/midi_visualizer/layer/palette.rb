require 'color'

module MIDIVisualizer
  module Layer
    class Palette
      def initialize(color_a, color_b, steps = nil)
        @color_a = color_a.to_rgb.to_a
        @color_b = color_b.to_rgb.to_a
        
        if steps # Discrete palette
          @palette = to_a steps
          define_singleton_method :[] do |index|
            index =
              if index > 1.0
                @palette.length - 1
              elsif index < 0.0
                0
              else
                (index * (@palette.length - 1)).round
              end
            
            @palette[index]
          end
        else # Continuous palette
          define_singleton_method(:[]) { |pos| mix_ab pos }
        end
      end
      
      private
      
      def to_a(n)
        n.times.map { |i| mix_ab(i.to_f / (n - 1)).freeze }
      end
      
      # Mix color A with color B
      #
      # r = 0 -> 100 % of color A
      # r = 1 -> 100 % of color B
      def mix_ab(r)
        Color::RGB.new(
          *@color_a.map.with_index { |e,i| e*(1-r) + @color_b[i]*r}, 1.0)
      end
    end
  end
end