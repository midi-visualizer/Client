module MIDI
  class Event
    attr_reader :timestamp

    def initialize(midi_data)
      @timestamp = midi_data[:timestamp]
    end

    class << self
      def initialize
        @event_classes = []
      end

      def inherited(subclass)
        @event_classes << subclass
      end

      def matches?(_)
        true
      end

      def match(midi_data)
        # Try to match subclasses first, otherwise match us
        child_class = @event_classes.find { |klass| klass.match midi_data }
        child_class || (matches?(midi_data) && self)
      end
    end
  end
end
