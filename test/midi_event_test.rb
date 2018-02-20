require 'test_helper'

class TestEvent < MIDIVisualizer::MIDI::Event
  class << self
    def matches?(status, _)
      status == 0xF0
    end
  end
end

describe MIDIVisualizer::MIDI::Event do
  subject { MIDIVisualizer::MIDI::Event }

  let(:event_timestamp) { Time.now.to_f }
  let(:event_channel) { rand 0...16 }
  let(:event_code) { 0xF0 + event_channel }
  let(:event_data) { { data: [event_code, 0, 0], timestamp: event_timestamp } }
  let(:event) { subject.new event_data }

  describe '.match' do
    it 'returns an instance of the matched class' do
      event = subject.match event_data

      assert(TestEvent === event)
      assert_equal(event_data[:data], event.data)
      assert_equal(event_timestamp, event.timestamp)
    end

    it 'returns an instance of the base class when no match' do
      data        = event_data.dup
      data[:data] = data[:data].dup
      data[0]     = 0xFF

      event = subject.match data

      assert(subject === event)
    end

    it 'freeses all mutable data' do
      event = subject.match event_data

      assert(event.data.frozen?)
      assert(event.timestamp.frozen?)
    end
  end

  describe '#channel' do
    it 'returns the channel number' do
      assert_equal event_channel, event.channel
    end
  end
end
