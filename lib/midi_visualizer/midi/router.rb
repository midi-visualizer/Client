module MIDI
  class Router
    def initialize
      @note_queue = Queue.new
    end
    
    # Expects data on the form { :data => [144, 60, 100], :timestamp => 1024 }
    def push_event(event)
      case event[:data][0]
      when 0x90 # Note on
        @note_queue.push(
          NoteOn.new(event[:data][1], event[:data][2], event[:timestamp])
        )
      when 0x80 # Note off
        @note_queue.push(
          NoteOff.new(event[:data][1], event[:data][2], event[:timestamp])
        )
      end
    end
    
    def each_note
      return to_enum(__callee__) unless block_given?
      yield @note_queue.pop until @note_queue.empty?
    end
    
    Note = Struct.new(:note, :velocity, :timestamp)
    
    class NoteOn  < Note; end
    class NoteOff < Note; end
  end
end