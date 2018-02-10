require 'rubyserial'
require 'unimidi'
require 'color'

C4_OFFSET = 72

port = Serial.new '/dev/tty.wchusbserialfd120', 115200

sleep 3
puts port.read(200)

@buffer = Array.new(44, 0)

def update(port)
  44.times { |i| @buffer[i] = 0 if  @buffer[i].nil? }
  $stdout.puts @buffer.pack('C*').inspect
  port.write('W' + @buffer.pack('C*'))
end

def handle_midi_msg(d)
  $stdout.puts(d.inspect)
  led, val =
    if (d[0] & 0xF0) == 144
      [(d[1] & 0x7F) - C4_OFFSET, 1]
    elsif (d[0] & 0xF0) == 128
      [(d[1] & 0x7F) - C4_OFFSET, 0]
    else
      [-1, 0]
    end
    
  if (0...11) === led
    @buffer[led * 4] = val == 0 ? 0 : 128
    $stdout.puts led, val
  end
end

begin
  256.times do |v|
    c = Color::HSL.from_fraction(v / 256.0, 0.5, 0.5).to_rgb
    
    11.times do |i|
      @buffer[i*4 + 0] = c.red
      @buffer[i*4 + 1] = c.green
      @buffer[i*4 + 2] = c.blue
    end
    
    update port
    sleep(0.2)
  end
ensure
  port.close
end

# begin
#   input = UniMIDI::Input.all[1]
#   input.open do |input|
#     $stdout.puts "send some MIDI to your input now..."
#
#     loop do
#       m = input.gets_data
#       next unless m
#
#       loop do
#         d = m.shift 3
#         handle_midi_msg d
#         break if m.empty?
#       end
#
#       update port
#     end
#   end
# ensure
#   port.close
# end
