require 'test_helper'

class TestEvent < MIDIVisualizer::MIDI::Event
  class << self
    def matches?(midi_data)
      midi_data[0] == 0xFF
    end
  end
end

describe MIDIVisualizer::MIDI::Event do
  subject { MIDIVisualizer::MIDI::Event }
  
  let(:event_timestamp) { Time.now.to_f }
  let(:event_code) { 0xFF }
  let(:event_data) { { data: [event_code, 0, 0], timestamp: event_timestamp } }
  
  describe '.select_class' do
    it 'returns the base class in case of no match' do
      klass = subject.select_class [0, 0, 0]
      assert_equal subject, klass
    end
    
    it 'returns the subclass in case of a match' do
      klass = subject.select_class event_data[:data]
      assert_equal TestEvent, klass
    end
  end
  
  describe '.match' do
    it 'returns an instance of the matched class' do
      event = subject.match event_data

      assert(TestEvent === event)
      assert_equal(event_data[:data], event.data)
      assert_equal(event_timestamp, event.timestamp)
    end
    
    it 'freeses all mutable data' do
      event = subject.match event_data
      
      assert(event.data.frozen?)
      assert(event.timestamp.frozen?)
    end
  end
end
