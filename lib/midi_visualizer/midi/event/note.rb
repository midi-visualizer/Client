module MIDIVisualizer
  module MIDI
    class Event
      class Note < Event
        MASK = 0xEF
        DATA = 0x80
        
        def note
          data[1]
        end
        
        def velocity
          data[2]
        end
        
        def off?
          data[0] == DATA
        end
        
        def on?
          !off?
        end
        
        class << self
          def matches?(midi_data)
            (midi_data[0] & MASK) == DATA
          end
        end
      end
    end
  end
end
