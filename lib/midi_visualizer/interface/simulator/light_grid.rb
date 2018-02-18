require 'thread'

require 'midi_visualizer/interface/simulator/light_column'

module MIDIVisualizer
  module Interface
    class Simulator
      require 'ruby2d'
      
      class LightGrid
        def initialize(margin: 40, num_columns: 8, num_rows: 8)
          width  = Application.get :width
          height = Application.get :height
          
          spacing = (width - 2 * margin).to_f / (num_columns - 1)
          @num_rows = num_rows
          @columns =
            num_columns.times.map do |i|
              LightColumn.new x: margin + (i * spacing).round,
                         from: margin, to: (height - margin),
                         num_lights: num_rows
            end
          
          @semaphore = Mutex.new
          @colors = Array.new(num_rows * num_columns) { Array.new(4, 1.0) }
        end
      
        # Actually update the colors
        def update!
          @semaphore.synchronize do
            # Transfer the contents of @colors to the buffers
            @columns.each.with_index do |column, i_column|
              color_index = (i_column + 1) * @num_rows
              column.each do |light|
                color_index -= 1
                light.color = @colors[color_index]
              end
            end
          end
        end
        
        # Write to the grid
        def write(rgb)
          @semaphore.synchronize do
            @colors.each_with_index do |c,i|
              c[0], c[1], c[2] = rgb[i].r, rgb[i].g, rgb[i].b
            end
          end
        end
      end
    end
  end
end