module MIDIVisualizer
  module MIDI
    class Event
      class Aftertouch < Event
        STATUS = 0xA0

        def note
          data[1]
        end

        def preassure
          data[2]
        end

        class << self
          def matches?(status, _)
            status == STATUS
          end
        end
      end
    end
  end
end
