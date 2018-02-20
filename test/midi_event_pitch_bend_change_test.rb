require 'test_helper'

describe MIDIVisualizer::MIDI::Event::PitchBendChange do
  subject { MIDIVisualizer::MIDI::Event::PitchBendChange }

  let(:channel)  { rand 1...16 }
  let(:bend)     { rand 0..(2**14) - 0x2000 }
  let(:event_data) do
    bend_low  = (bend + 0x2000) & 0x7F
    bend_high = (bend + 0x2000) >> 7
    {
      data: [0xE0 + channel, bend_low, bend_high],
      timestamp: Time.now.to_f
    }
  end

  let(:msg) { subject.new event_data }

  describe '.matches?' do
    it 'returns true for pitch bend change messages' do
      assert subject.matches?(0xE0, [0xE0 + channel, 0, 0])
    end

    it 'returns false for other messages' do
      refute subject.matches?(0xB0, [0xB0, 0, 0])
    end
  end

  describe '#raw' do
    it 'returns the raw pitch bend value' do
      assert_equal bend, msg.raw
    end
  end

  describe '#value' do
    it 'returns the pitch bend as a float in the range -1..1' do
      assert_in_epsilon bend.to_f / 0x2000, msg.value
    end
  end
end
