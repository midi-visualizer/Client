class Animation
  attr_reader :v_end
  
  def initialize(t_start, t_end, v_start, v_end)
    @t_start = t_start
    @t_end   = t_end
    
    @v_start = v_start.to_f
    @v_end   = v_end.to_f
  end
  
  def active?(t)
    t <= @t_end
  end
  
  def value(t)
    r = (t - @t_start) / (@t_end - @t_start)
    @v_start + r * (@v_end - @v_start)
  end
  
  def interpolation(from, to, steps)
    delta = to - from
    time_scaling = delta / (steps - 1)
    ->(t) { from + time_scaling * t }
  end
end