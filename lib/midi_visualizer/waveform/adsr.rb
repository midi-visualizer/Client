module MIDIVisualizer
  module Waveform
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
        @last_update_t     = t
        @last_update_value = current_value
        @state       = :attack
      end

      def release!(t, params: {})
        @last_update_value = value(t, params: params)
        @last_update_t     = t
        @state             = :release
      end

      def value(t, params: {})
        params.merge!(DEFAULT_PARAMS) { |_, v, _| v }

        current_value =
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

        @last_update_t     = t
        @last_update_value = current_value
      end

      def done?
        @state == :done
      end

      private

      # Returns either a symbol if the effect should transition to another state
      # or a numeric value.
      def attack_state(t, params)
        dt         = t - @last_update_t
        dv         = params[:attack_slope] * dt
        next_value = @last_update_value + dv

        next_value > params[:attack_value] ? :decay : next_value
      end

      # Returns either a symbol if the effect should transition to another state
      # or a numeric value.
      def decay_state(t, params)
        decay_min  = params[:attack_value] * params[:decay_value]
        dt         = t - @last_update_t
        dv         = -params[:decay_slope] * dt
        next_value = @last_update_value + dv
        
        next_value < decay_min ? :sustain : next_value
      end

      # Returns a constant value.
      def sustain_state(_, params)
        params[:decay_value] * params[:attack_value]
      end

      # Returns either a symbol if the effect should transition to another state
      # or a numeric value.
      def release_state(t, params)
        dt         = t - @last_update_t
        dv         = -params[:release_slope] * dt
        next_value = @last_update_value + dv

        next_value <= 0 ? :done : next_value
      end
    end
  end
end
