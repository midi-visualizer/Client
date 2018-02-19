module MIDIVisualizer
  module Effect
    class ADSR
      DEFAULT_PARAMS = {
        attack_slope: 1.0,
        decay_value: 0.8,
        decay_slope: 1.0,
        release_slope: 1.0
      }.freeze

      def initialize(t, current_value = 0.0)
        @start_t     = t
        @start_value = current_value
        @state       = :attack
      end
      
      def release!(t, params: {})
        @start_value = value(t, params: params)
        @start_t     = t
        @state       = :release
      end

      def value(t, params: {})
        params.merge!(DEFAULT_PARAMS) { |_, v, _| v }
        
        loop do
          next_state =
            case @state
            when :attack  then attack_state  t, params
            when :decay   then decay_state   t, params
            when :sustain then sustain_state t, params
            when :release then release_state t, params
            else break 0.0
            end
          break next_state unless Symbol === next_state
          @state = next_state
        end
      end
      
      private
      
      def attack_state(t, params)
        dt = t - @start_t
        return :decay if dt > (1.0 - @start_value) / params[:attack_slope]
        
        @start_value + dt * params[:attack_slope]
      end
      
      def decay_state(t, params)
        dt = t - @start_t - (1.0 - @start_value) / params[:attack_slope]
        return :sustain if dt > (1.0 - params[:decay_value]) / params[:decay_slope]
        
        1.0 - dt * params[:decay_slope]
      end
      
      def sustain_state(_, params)
        params[:decay_value]
      end
      
      def release_state(t, params)
        dt = t - @start_t
        return :done if dt > @start_value / params[:release_slope]
        
        @start_value - dt * params[:release_slope]
      end
    end
  end
end
