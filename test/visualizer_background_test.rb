require 'test_helper'

describe MIDIVisualizer::Visualizer::Background do
  subject { MIDIVisualizer::Visualizer::Background }

  let(:color_a) { Color::RGB.new rand, rand, rand, 1.0 }
  let(:color_b) { Color::RGB.new rand, rand, rand, 1.0 }
  let(:palette) { MIDIVisualizer::Layer::Palette.new color_a, color_b }

  let(:ctx) do
    MIDIVisualizer::Layer::Ctx.new 1, rows: 2, columns: 3, palettes: [palette]
  end

  let(:params) { {} }
  let(:background) { subject.new(ctx[0]) }

  describe '.new' do
    
  end
end
