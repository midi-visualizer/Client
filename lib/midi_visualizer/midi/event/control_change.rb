module MIDIVisualizer
  module MIDI
    class Event
      class ControlChange < Event
        STATUS = 0xB0

        def number
          data[1]
        end

        def value
          data[2]
        end

        class << self
          def matches?(status, midi_data)
            status == STATUS && midi_data[1] < 120
          end
        end
      end
    end
  end
end
