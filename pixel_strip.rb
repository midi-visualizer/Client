require 'color'
require 'serialport'
require 'highline'

require_relative 'state'

class PixelStrip
  SERIAL_BAUD = 115200
  NUM_PIXELS  = 11
  
  def initialize(port, palette = [])
    @buffer  = Array.new(NUM_PIXELS) { Color::RGB.new }
    @port    = port
    @palette = palette
  end
  
  def ready?
    @port.write('I')
    sleep 0.5
    @port.read(256)&.include?('OK')
  end
  
  def update!(buffer = nil)
    NUM_PIXELS.times { |i| self[i] = buffer[i] } if buffer
    @port.write('W' +
      @buffer.flat_map { |pixel| transform_pixel(pixel) }.pack('C*'))
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
  
  def palette=(palette)
    @palette = palette
  end
  
  def [](pixel_index)
    @buffer[pixel_index]
  end
  
  def []=(pixel_index, color)
    case color
    when State
      @buffer[pixel_index] = color.to_color
      
    when Integer
      @buffer[pixel_index] = @palette[color]
    when Float
      if color > 1.0
        color = 1.0
      elsif color < 0
        color = 0.0
      end
      
      @buffer[pixel_index] = @palette[(color * (@palette.length - 1)).round]
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
  
  def gamma_correct(value)
    case value
    when Complex then 0
    else
      value**2.4
    end
  end
  
  # Crude alg. taken from
  # https://stackoverflow.com/questions/40312216/converting-rgb-to-rgbw
  def transform_pixel(pixel)
    c = pixel.to_a
    
    # DEBUG: Return unaltered array
    #return c.push(0).map{ |v| (v*255).round }
    
    tm = c.max
    return [0,0,0,0] if tm == 0
    
    multiplier = 1.0 / tm
    h = c.map { |v| v * multiplier }
        
    luminance = ((h.max + h.min) / 2 - 0.5) * 2 * tm
    
    c.push(luminance)
    c.map! { |v| (gamma_correct(v)*255).round }
    c
  end
end