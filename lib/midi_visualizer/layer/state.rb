module MIDIVisualizer
  module Layer
    class State < Struct.new(:p, :i)
      def initialize(p = 0.0, i = 0.0)
        super
      end
    end
  end
end