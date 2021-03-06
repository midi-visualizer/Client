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
        Event.match(data).tap { |event| @event_queue.push event }
      end

      def subscribe(listener, event_class = nil)
        if event_class
          raise ArgumentError unless event_class <= Event
        else
          event_class = :all
        end

        @listeners[event_class] << listener
        nil # Do not leak the listeners
      end

      def run
        until @event_queue.empty?
          event = @event_queue.shift

          (@listeners[event.class] + @listeners[:all]).each do |listener|
            listener.handle_midi_event event
          end
        end
      end
    end
  end
end
