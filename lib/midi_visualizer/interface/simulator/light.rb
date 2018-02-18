module Interface
  class Simulator
    require 'ruby2d'
    
    class Light
      MASK_SIZE = 20
    
      def initialize(x:, y:, color:)
        offset = MASK_SIZE / 2
        x -= offset
        y -= offset
    
        @mask  = Image.new  x: x, y: y, z: 1, path: 'interface/simulator/assets/light-mask.png'
        @light = Square.new x: x, y: y, size: MASK_SIZE, color: color
      end
    
      def color=(color)
        @light.color = color
      end
    end
  end
end