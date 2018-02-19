module MIDIVisualizer
  module MIDI
    # Event
    #
    # The base class of event represents the default midi event object. Sub
    # classes can extend the functionality further to implement more specialized
    # behaviour. As long as the subclass implements .matches? it will be
    # considered for instantiation when new data arrives.
    class Event
      attr_reader :timestamp, :data

      def initialize(midi_data)
        @data      = midi_data[:data]
        @timestamp = midi_data[:timestamp]
      end

      class << self
        def inherited(subclass)
          (@sub_classes ||= []) << subclass
        end

        # The base class always matches the event data.
        def matches?(_)
          true
        end

        # Select a subclass based on the data part of the raw midi event.
        #
        # Returns a subclass of Event, or Event itself if no subclass matches.
        def select_class(midi_data)
          child_class = (@sub_classes ||= []).find do |klass|
            klass.select_class midi_data
          end
          child_class || (matches?(midi_data) && self)
        end

        # Returns an instance of the subclass of Event that matches the event
        # data. Only the :data field can be used for matching.
        def match(event_data)
          event_data[:data].freeze
          event_data[:timestamp].freeze

          select_class(event_data[:data]).new(event_data).freeze
        end
      end
    end
  end
end
