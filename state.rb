 require 'color'
 
 class State
   attr_accessor :intensity
   
   def initialize(color, intensity = 1.0)
     @color     = color.freeze
     @intensity = intensity
   end
      
   def to_color
     Color::RGB.new @color.r * intensity,
                    @color.g * intensity,
                    @color.b * intensity,
                    1.0
   end
 end