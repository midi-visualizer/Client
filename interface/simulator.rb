require_relative 'simulator/fps'
require_relative 'simulator/light_grid'

module Interface
  class Simulator
    require 'ruby2d'
    
    attr_reader :rows, :columns
    
    ROWS    = 8
    COLUMNS = 8
    
    def initialize(rows = ROWS, columns = COLUMNS)
      @rows    = rows
      @columns = columns
      
      @grid = LightGrid.new num_rows: rows, num_columns: columns
      @last_update = Time.now.to_f
      @fps = Fps.new x: 5, y: 5
      
      Application.set title: "MIDI Visualizer"
    end
    
    def open
      Application.update do
        colors = yield if block_given?
        
        @grid.write(colors)
        
        this_update = Time.now.to_f
        @fps.set 1.0 / (this_update - @last_update)
        @last_update = this_update
        
        @fps.update!
        @grid.update!
      end
      
      Application.show
    end
  end
end