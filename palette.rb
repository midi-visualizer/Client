require 'color'

class Palette
  def initialize(color_a, color_b)
    @color_a = color_a.to_rgb
    @color_b = color_b.to_rgb
  end

  def to_a(n)
    a = @color_a.to_a
    b = @color_b.to_a

    n.times.map do |i|
      r = i.to_f / (n - 1)
      Color::RGB.new(*a.map.with_index { |e, i| e*(1-r) + b[i]*r}, 1.0)
    end
  end
end