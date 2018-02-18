require 'test_helper'
require 'midi_visualizer/Visualizer'
require 'midi_visualizer/interface/simulator'
require 'midi_visualizer/layer/palette'
require 'midi_visualizer/visualizer/background'

include MIDIVisualizer

PALETTE_BG = Layer::Palette.new(Color::RGB.new(0x40, 0xFF, 0x60),
                                Color::RGB.new(0xFF, 0x00, 0x00))
                                
PALETTE_FG = Layer::Palette.new(Color::RGB.new(0x00, 0x00, 0x00),
                                Color::RGB.new(0xFF, 0xFF, 0xFF))

viz = Visualizer.new Interface::Simulator.new(12, 8), PALETTE_BG, PALETTE_FG

# # Setup foreground
viz.foreground.each { |state| state.p = 1.0 }

class LFO
  def initialize(layer, f = 1.0, amplitude = 0.5, bias = 0.5)
    @func = ->(t, phase) {
      amplitude * Math.cos( t * 2*Math::PI * f + phase) + bias }
    @phases = Array.new(layer.num_states) { rand * 2 * Math::PI * 1.0  }
  end
  
  def next_state(t)
    @phases.map { |phase| @func.(t, phase) }
  end
end

class Gauss
  def initialize(layer, f, std)
    mean_state = (rand * layer.num_states).round
    @layer = layer
    @weight_map = layer.num_states.times.map do |s|
      d = layer.distance(s, mean_state)
      Math.exp(-0.5 * (d/std)**2)
    end
        
    @osc_x = ->(t) { 0.5 + 0.2 * Math.cos(t * f * 2*Math::PI) }
    @osc_y = ->(t) { 0.5 + 0.2 * Math.sin(t * f * 2*Math::PI) }
  end
  
  def next_state(t)
    @layer.num_states.times.map do |i|
      x, y = @layer.position i
      
      dx = @osc_x.(t) - x
      dy = @osc_y.(t) - y
            
      Math.exp(-0.5 * ((dx**2 + dy**2)/0.05))
    end
  end
end

gauss = Gauss.new viz.foreground, 0.2, 0.1

lfo_f = LFO.new viz.foreground, 0.1, 0.1, 0.9

viz.background.intensity = 0.3

viz.run do |t, background, foreground|
  foreground_intensity = gauss.next_state(t)
  foreground_palette = lfo_f.next_state(t)
  
  viz.num_states.times do |i|
    foreground[i].i = foreground_intensity[i]
    foreground[i].p = foreground_palette[i]
  end
end