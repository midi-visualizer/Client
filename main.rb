require 'color'
require 'unimidi'
require 'thread/process'

require_relative 'pixel_strip'
require_relative 'palette'
require_relative 'animation'

C4_OFFSET = 72

PALETTE = Palette.new(Color::RGB.new(0, 0, 0),
                      Color::RGB.new(0xFF, 0xFF, 0xFF)).to_a(256)

def handle_midi_msg(m, pixels)
  led, val =
    if (m[0] & 0xF0) == 144
      [(m[1] & 0x7F) - C4_OFFSET, 1]
    elsif (m[0] & 0xF0) == 128
      [(m[1] & 0x7F) - C4_OFFSET, 0]
    else
      [-1, 0]
    end

  if (0...11) === led
    $stdout.puts led, val
    color_index = m[2] / 11
    pixels[led] = val == 1 ? PALETTE[color_index] : COLOR_OFF
  end
end

state_channel = Thread.channel
midi_queue    = Queue.new

# random_walk_process =
#   Thread.process do
#     puts "Starting random walk"
#     state = Array.new(PixelStrip::NUM_PIXELS) { rand }
#
#     loop do
#       11.times do |i|
#         state[i] += 0.05 * (rand - 0.5)
#
#         if state[i] > 1.0
#           state[i] = 1.0
#         elsif state[i] < 0.0
#           state[i] = 0.0
#         end
#       end
#
#       state_channel.send state
#       sleep 0.016
#     end
#   end
  
# midi_process =
#   Thread.process do
#     puts 'Opening MIDI interface...'
#
#     midi_input = UniMIDI::Input.all[1]
#     midi_input.open do |input|
#       $stdout.puts 'Ready to receive MIDI'
#
#       loop do
#         sleep 0.001
#         d = input.gets_data
#         next unless d
#
#         d.each_slice 3 do |m|
#           p m
#           break unless m.length == 3
#
#           change =
#             case m[0]
#             when 0x90 then :on
#             when 0x80 then :off
#             else nil
#             end
#
#           next unless change
#
#           note = m[1] % 12
#           p [note, change]
#           midi_queue.push([note, change])
#         end
#       end
#     end
#   end

midi_process =
  Thread.process do
    loop do
      # wait a random time t
      t = rand * 5
      sleep t
      note = (rand * 10).round
      midi_queue.push([note, :on])

      t = rand * 2
      sleep t
      midi_queue.push([note, :off])
    end
  end

animation_process =
  Thread.process do
    puts "Starting animation process"
    animations = Array.new(11) { [] }

    loop do
      t, state = receive
      
      until midi_queue.empty?
        i, s = midi_queue.pop
        
        case s
        when :on
          animations[i] = [
            Animation.new(      t, t + 0.2, state[i], 1.0),
            Animation.new(t + 0.2, t + 2.0, 1, 0.8)
          ]
        when :off
          animations[i] = [
            Animation.new(      t, t + 2, state[i], 0)
          ]
        end
      end
      
      animations.each_with_index do |animation_queue, i|
        next if animation_queue.empty? || animation_queue.first.active?(t)
        state[i] = animation_queue.shift.v_end
      end
      
      next_state =
        animations.map.with_index do |animation_queue, i|
          if animation_queue.empty?
            state[i]
          else
            animation_queue.first.value(t)
          end
        end

      state_channel.send next_state
    end
  end

# Open the port and wait for the device to initialize
PixelStrip.open_cli do |pixels|
  pixels.palette = PALETTE
  
  t     = Time.now.to_f
  state = Array.new(11, 0.0)
  # Request the first frame
  animation_process.send [t, state]
  
  loop do
    t     = Time.now.to_f + 1.0 / 60
    state = state_channel.receive
    
    # Request next t
    animation_process.send [t, state]
    
    sleep 0.0005 while t > Time.now.to_f
    
    pixels.update! state
  end
end