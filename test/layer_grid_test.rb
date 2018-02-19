require 'test_helper'

describe MIDIVisualizer::Layer::Grid do
  subject { MIDIVisualizer::Layer::Grid }
  let(:rows)    { rand(1..10) }
  let(:columns) { rand(1..10) }
  let(:width)   { rand(1.0..2.0) }
  let(:height)  { rand(1.0..2.0) }
  
  describe '.new' do
    it 'accepts two arguments' do
      grid = subject.new rows, columns
      
      assert_equal rows, grid.rows
      assert_equal columns, grid.columns
      assert_equal 1.0, grid.width
      assert_equal 1.0, grid.height
    end
    
    it 'accepts an aspect ratio' do
      grid = subject.new rows, columns, aspect_ratio: (width / height)
      
      if width < height
        assert_equal 1.0, grid.height
        assert_in_epsilon width / height, grid.width
      else
        assert_equal 1.0, grid.width
        assert_in_epsilon height / width, grid.height
      end
    end
  end
end
