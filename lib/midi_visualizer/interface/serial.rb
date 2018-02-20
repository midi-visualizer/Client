require 'serialport'
require 'highline'

module MIDIVisualizer
  module Interface
    class Serial
      SERIAL_BAUD = 115200
      NUM_PIXELS  = 11
      GAMMA       = 2.4
      PORTS_DIR   = '/dev/tty.*'.freeze

      def initialize(port_path = nil, ports_dir = PORTS_DIR)
        @port_path = port_path
        @ports_dir = ports_dir
      end

      def open
        if @port_path
          port_path = @port_path
        else
          ports = Dir[@ports_dir].reject { |port| port.include? 'Bluetooth' }
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
        end

        puts "Connecting to \"#{port_path}\"..."
        @port = ::SerialPort.new port_path, baud, 8, 1, ::SerialPort::NONE
        @port.read_timeout = 50

        loop do
          break if ready?
          sleep 0.1
        end

        puts 'Connected to pixel strip'

        loop do
          t_done = Time.now.to_f + 1.0/60
          colors = yield
          t = Time.now.to_f
          sleep t_done - t if t_done > t

          update! colors
        end
      rescue Interrupt

      ensure
        port.close if port
      end

      private

      def ready?
        @port.write('I')
        sleep 0.5
        @port.read(256)&.include?('OK')
      end

      def update!(buffer)
        @port.write('W' +
          buffer.flat_map { |p| self.class.transform_pixel(p) }.pack('C*'))
      end

      class << self
        def gamma_correct(value)
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
        # Returns an array of four integer color values (r,g,b,w) between 0 and
        # 255.
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
    end
  end
end