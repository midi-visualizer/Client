module MIDIVisualizer
  module MIDI
    # Event
    #
    # The base class of event represents the default midi event object. Sub
    # classes can extend the functionality further to implement more specialized
    # behaviour. As long as the subclass implements .matches? it will be
    # considered for instantiation when new data arrives.
    class Event
      STATUS_MASK  = 0xF0
      CHANNEL_MASK = 0x0F
      
      attr_reader :timestamp, :data

      def initialize(midi_data)
        @data      = midi_data[:data]
        @timestamp = midi_data[:timestamp]
      end

      def channel
        @data[0] & CHANNEL_MASK
      end

      class << self
        def inherited(subclass)
          (@sub_classes ||= []) << subclass
        end

        # The base class always matches the event data.
        def matches?(_, _)
          true
        end

        # Returns an instance of the subclass of Event that matches the event
        # data. Only the :data field can be used for matching.
        def match(event_data)
          event_data[:data].freeze
          event_data[:timestamp].freeze
          status = event_data[:data][0] & STATUS_MASK
          select_class(status, event_data[:data]).new(event_data).freeze
        end

        protected

        # Select a subclass based on the data part of the raw midi event.
        #
        # Returns a subclass of Event, or Event itself if no subclass matches.
        def select_class(status, midi_data)
          child_class = (@sub_classes ||= []).find do |klass|
            klass.select_class status, midi_data
          end
          child_class || (matches?(status, midi_data) && self)
        end
      end
    end
  end
end
