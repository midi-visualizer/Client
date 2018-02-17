require 'color'
require 'serialport'
require 'highline'

# TODO: Remove internal buffer from pixel strip.

class PixelStrip
  SERIAL_BAUD = 115200
  NUM_PIXELS  = 11
  GAMMA       = 2.4
  
  def initialize(port)
    @buffer  = Array.new(NUM_PIXELS) { Color::RGB.new }
    @port    = port
  end
  
  def count
    NUM_PIXELS
  end
  
  def ready?
    @port.write('I')
    sleep 0.5
    @port.read(256)&.include?('OK')
  end
  
  def update!(buffer = nil)
    NUM_PIXELS.times { |i| self[i] = buffer[i] } if buffer
    @port.write('W' +
      @buffer.flat_map { |pixel| self.class.transform_pixel(pixel) }.pack('C*'))
  end
  
  def clear!
    @buffer.map! { Color::RGB.new }
    update!
  end
  
  def each
    return to_enum(__callee__) unless block_given?
    
    NUM_PIXELS.times do |i|
      yield i
    end
  end
    
  def [](pixel_index)
    @buffer[pixel_index]
  end
  
  def []=(pixel_index, color)
    case color
    when Color::RGB
      @buffer[pixel_index] = color
    else raise ArgumentError
    end
  end
  
  def close
    #clear!
    @port.close
  end
  
  def self.open(port_path, baud = SERIAL_BAUD)
    port = SerialPort.new port_path, baud, 8, 1, SerialPort::NONE
    port.read_timeout = 50
    pixel_strip = new(port)
    return pixel_strip unless block_given?
    begin
      loop do
        break if pixel_strip.ready?
        sleep 0.1
      end
      
      puts 'Connected to PixelStrip'
      
      yield pixel_strip
    rescue Interrupt
    ensure
      pixel_strip.close
    end
  end
  
  # TODO: Look for a simulator and use that if no pixel strip is available.
  def self.open_cli(ports_dir = '/dev/tty.*', &block)
    ports = Dir[ports_dir].reject { |port| port.include? 'Bluetooth' }
    port_path =
      if ports.length == 0
        puts 'No serial ports available'
        exit(1)
      elsif ports.length == 1
        ports.first
      else
        HighLine.new.choose do |menu|
          menu.prompt = 'Choose a serial port:'
          menu.choices(*ports)
        end
      end
    
    puts "Connecting to \"#{port_path}\"..."
    
    open port_path, &block
  end
  
  private
  
  def self.gamma_correct(value)
    case value
    when Complex then 0
    else
      value**GAMMA
    end
  end
  
  # Crude alg. taken from
  # https://stackoverflow.com/questions/40312216/converting-rgb-to-rgbw
  #
  # pixel.to_a must produce an array of three values between 0 and 1
  # representing the red, green and blue color channels.
  #
  # Returns an array of four integer color values (r,g,b,w) between 0 and 255.
  #
  # TODO: Implement this as using fixed point math.
  def self.transform_pixel(pixel)
    c = pixel.to_a
    raise ArgumentError, 'Invalid pixel format' unless c.length == 3
    
    # DEBUG: Return unaltered array
    #return c.push(0).map{ |v| (v*255).round }
    
    tm = c.max
    return [0,0,0,0] if tm == 0
    
    # Normalize components
    multiplier = 1.0 / tm
    h = c.map { |v| v * multiplier }
    
    whiteness = [((1 + h.min) - 1) * tm, 1].min
    #              ^- h.max == 1
    
    # Remove whiteness from original color channels
    c.map! { |v| [v - whiteness, 0].max }
    
    c.push whiteness
    # Gamma correct everything, scale and round
    c.map! { |v| (gamma_correct(v)*255).round }
  end
end