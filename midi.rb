require 'unimidi'

input = UniMIDI::Input.all[1]
input.open do |input|
  $stdout.puts "send some MIDI to your input now..."

  loop do
    m = input.gets
    $stdout.puts(m)
    #$stdout.puts(m.inspect) if m
    if m
      #input.clear_buffer
    end
  end

end