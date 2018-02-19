require 'test_helper'

class TestRouterEvent < MIDIVisualizer::MIDI::Event
  class << self
    def matches?(midi_data)
      midi_data[0] == 0xFF
    end
  end
end

class TestEventListener
  attr_accessor :last_event

  def initialize
    @last_event = nil
  end

  def handle_midi_event(event)
    @last_event = event
  end
end

describe MIDIVisualizer::MIDI::Router do
  subject { MIDIVisualizer::MIDI::Router }

  let(:event_data) { { data: [0xFF, 0, 0], timestamp: Time.now.to_f } }
  let(:router) { subject.new }
  let(:listener) { TestEventListener.new }

  describe '#push' do
    it 'creates an event' do
      event = router.push event_data
      assert_equal TestEvent, event.class
      assert event.frozen?
    end
  end

  describe '#subscribe' do
    it 'adds the listener to the list of subscribers' do
      router.subscribe listener, TestEvent
      event = router.push event_data
      assert_nil listener.last_event
      router.run
      assert_equal event, listener.last_event
    end
  end
end
