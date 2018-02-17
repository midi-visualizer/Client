require_relative 'Visualizer'
require_relative 'interface/simulator'

require_relative 'layer/palette'

PALETTE = Layer::Palette.new(Color::RGB.new(0x00, 0x00, 0xFF),
                             Color::RGB.new(0xFF, 0x00, 0x00))

viz = Visualizer.new Interface::Simulator.new(12, 8), PALETTE

# Setup background
viz.background.each { |state| state.i = 1.0 }

# # Setup foreground
viz.foreground.each { |state| state.p = 1.0 }

class LFO
  def initialize(num_states, f = 1.0, amplitude = 0.5, bias = 0.5)
    @func = ->(t, phase) {
      amplitude * Math.cos( t * 2*Math::PI * f + phase) + bias }
    @phases = Array.new(num_states) { rand * 2 * Math::PI * 0.3  }
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
    
    @osc = ->(t) { 0.5 + 0.5 * Math.sin(t * f * 2*Math::PI) }
    
    @osc_x = ->(t) { 0.5 + 0.4 * Math.cos(t * f * 2*Math::PI) }
    @osc_y = ->(t) { 0.5 + 0.4 * Math.sin(t * f * 2*Math::PI) }
  end
  
  def next_state(t)
    @layer.num_states.times.map do |i|
      x, y = @layer.position i
      
      dx = @osc_x.(t) - x
      dy = @osc_y.(t) - y
            
      Math.exp(-0.5 * ((dx**2 + dy**2)/0.01))
    end
  end
end

lfo   = LFO.new 12*8, 0.2, 0.15, 0.15
gauss = Gauss.new viz.foreground, 0.2, 0.1

lfo_f = LFO.new 12*8, 0.1, 0.1, 0.9

viz.background.intensity = 0.3

viz.run do |t, background, foreground|
  background_palette = lfo.next_state(t)
  foreground_intensity = gauss.next_state(t)
  foreground_palette = lfo_f.next_state(t)
  
  (12*8).times do |i|
    background[i].p = background_palette[i]
    foreground[i].i = foreground_intensity[i]
    foreground[i].p = foreground_palette[i]
  end
end