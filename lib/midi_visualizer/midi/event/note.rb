module MIDIVisualizer
  module MIDI
    class Event
      class Note < Event
        MASK = 0xE0
        STATUS = 0x80

        def note
          data[1]
        end

        def velocity
          data[2]
        end

        def off?
          (data[0] & STATUS_MASK) == STATUS
        end

        def on?
          !off?
        end

        class << self
          def matches?(status, _)
            status & MASK == STATUS
          end
        end
      end
    end
  end
end
