module MIDIVisualizer
  module MIDI
    # Router
    #
    # The MIDI Router provides other components in the code a way to subscribe
    # to MIDI events. The router collects events asynchronously and, when told
    # to run, notifies the listeners synchronously in the order that the events
    # arrived.
    #
    # All listeners have to do to receive events is to implement the instance
    # method #handle_midi_event.
    class Router
      def initialize
        @event_queue = Queue.new
        @listeners   = Hash.new { |h, k| h[k] = [] }
      end
  
      # Expects data on the form { :data => [144, 60, 100], :timestamp => 1024 }
      def push(data)
        event = Event.create_from_data(data)
        @event_queue.push event
      end
      
      def subscribe(listener, event)
        @listeners[event] << listener
      end
      
      def run
        until @event_queue.empty?
          event = @event_queue.shift
          
          @listeners[event].each do |listener|
            listener.handle_midi_event event
          end
        end
      end
    end
  end
end