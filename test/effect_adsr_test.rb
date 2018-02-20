require 'test_helper'

describe MIDIVisualizer::Effect::ADSR do
  subject { MIDIVisualizer::Effect::ADSR }

  let(:initial_value) { 0 }
  let(:adsr) { subject.new 0.0, 0.0 }
  let(:params) do
    {
      attack_slope:  1.0,
      decay_value:   0.5,
      decay_slope:   0.5,
      release_slope: 1.0
    }
  end

  describe '.value' do
    it 'returns 0 by at t = 0' do
      assert_equal 0.0, adsr.value(0, params: params)
    end

    it 'reaches 1 at t = 1' do
      assert_equal 1.0, adsr.value(1.0, params: params)
    end

    it 'falls back to 0.5 at t = 2' do
      assert_equal 0.5, adsr.value(2.0, params: params)
    end

    it 'remains at 0.5' do
      assert_equal 0.5, adsr.value(3.0, params: params)
    end
  end

  describe '.release!' do
    it 'triggers the release' do
      adsr.release! 3.0, params: params
      assert_equal 0.25, adsr.value(3.25, params: params)
      assert_equal 0.0, adsr.value(3.5, params: params)
    end

    it 'releases from the current value' do
      adsr.release! 1.0, params: params
      assert_equal 0.5, adsr.value(1.5, params: params)
      assert_equal 0.0, adsr.value(2.0, params: params)
    end
  end
end
