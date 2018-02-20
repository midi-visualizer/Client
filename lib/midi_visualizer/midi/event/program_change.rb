module MIDIVisualizer
  module MIDI
    class Event
      class ProgramChange < Event
        STATUS = 0xC0

        def number
          data[1]
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
