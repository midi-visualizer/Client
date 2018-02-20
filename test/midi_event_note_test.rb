require 'test_helper'

describe MIDIVisualizer::MIDI::Event::Note do
  subject { MIDIVisualizer::MIDI::Event::Note }

  let(:channel)  { rand 1...16 }
  let(:note)     { rand 0..127 }
  let(:velocity) { rand 0..127 }
  let(:event_data) do
    {
      data: [0x90 + channel, note, velocity],
      timestamp: Time.now.to_f
    }
  end

  let(:event_data_off) do
    {
      data: [0x80 + channel, note, velocity],
      timestamp: Time.now.to_f
    }
  end

  let(:msg) { subject.new event_data }
  let(:msg_off) { subject.new event_data_off }

  describe '.matches?' do
    it 'returns true for note on messages' do
      assert subject.matches?(0x90, [0x90 + channel, 0, 0])
    end

    it 'returns true for note off messages' do
      assert subject.matches?(0x80, [0x80 + channel, 0, 0])
    end

    it 'returns false for other messages' do
      refute subject.matches?(0xB0, [0xB0, 0, 0])
    end
  end

  describe '#note' do
    it 'returns the note' do
      assert_equal note, msg.note
    end
  end

  describe '#velocity' do
    it 'returns the velocity' do
      assert_equal velocity, msg.velocity
    end
  end

  describe '#on?' do
    it 'returns true for note on messages' do
      assert msg.on?
    end

    it 'returns false for note off messages' do
      refute msg_off.on?
    end
  end

  describe '#off?' do
    it 'returns true for note off messages' do
      assert msg_off.off?
    end

    it 'returns false for note on messages' do
      refute msg.off?
    end
  end
end
