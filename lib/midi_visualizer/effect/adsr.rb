module MIDIVisualizer
  module Effect
    # Attack-Decay-Sustain-Release
    # ^
    # |  /\__________
    # | /            \
    # +--------------------> t
    #
    # This effect implements the waveform shown above using a FSM.
    #
    # TODO: Investigate the effects of chainging the params during operation.
    class ADSR
      DEFAULT_PARAMS = {
        attack_slope:  1.0,
        attack_value:  1.0,
        decay_value:   0.8, # Percentage of the attack_value
        decay_slope:   1.0,
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
            else 0.0
            end
          break next_state unless next_state.is_a? Symbol
          @state = next_state
        end
      end

      def done?
        @state == :done
      end

      private

      # Returns either a symbol if the effect should transition to another state
      # or a numeric value.
      def attack_state(t, params)
        slope = params[:release_slope]
        dt    = t - @start_t
        return :decay if dt > (params[:attack_value] - @start_value) / slope

        @start_value + dt * slope
      end

      # Returns either a symbol if the effect should transition to another state
      # or a numeric value.
      def decay_state(t, params)
        slope = params[:attack_slope]
        top   = params[:attack_value]
        decay = top * params[:decay_value]
        dt    = t - @start_t - (top - @start_value) / slope

        return :sustain if dt > (top - decay) / slope

        top - dt * slope
      end

      # Returns a constant value.
      def sustain_state(_, params)
        params[:decay_value] * params[:attack_value]
      end

      # Returns either a symbol if the effect should transition to another state
      # or a numeric value.
      def release_state(t, params)
        slope = params[:release_slope]
        dt    = t - @start_t
        return :done if dt > @start_value / slope

        @start_value - dt * slope
      end
    end
  end
end
