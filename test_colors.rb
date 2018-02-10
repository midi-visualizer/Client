require 'color'
require 'io/console'

require_relative 'pixel_strip'
require_relative 'palette'


def xyz_to_rgb(xyz)
  r =  xyz[:x] * 3.2404542 - xyz[:y] * 1.5371385 - xyz[:z] * 0.4985314
  g = -xyz[:x] * 0.9692660 + xyz[:y] * 1.8760108 + xyz[:z] * 0.0415560
  b =  xyz[:x] * 0.0556434 - xyz[:y] * 0.2040259 + xyz[:z] * 1.0572252

  {
    r: u(r),
    g: u(g),
    b: u(b)
  }
end

def u(i)
  if 0.0031308 <= i
    1.055 * i**(1/2.4) - 0.055
  elsif 0 <= i
    12.92 * i
  else
    -u(-i)
  end
end

def g(i)
  if i < (6.0/29.0) # Linear range
    3 * (6.0/29.0)**2 * (i - (4.0/29.0))
  else
    i**3
  end
end

def lab_to_xyz(lab)
  ll = (lab[:L] + 16) / 116
  
  {
    y: 1.0 * g(ll),
    x: 0.95047 * g(ll + lab[:a]/500),
    z: 1.08883 * g(ll - lab[:b]/200),
  }
end

def lab_to_rgb(lab)
  rgb = xyz_to_rgb(lab_to_xyz(lab))
  Color::RGB.new rgb[:r], rgb[:g], rgb[:b], 1.0
end

PixelStrip.open_cli do |pixels|
  
  # Two random colors
  color_a = Color::RGB.new(rand, rand, rand, 1.0)
  color_b = Color::RGB.new(rand, rand, rand, 1.0)
  
  lab_color_a = color_a.to_lab.freeze
  lab_color_ab = Hash[color_b.to_lab.map { |k,v| [k, v - lab_color_a[k]] }]
  
  p lab_color_ab
  
  t = 0.0
  dir = 1
  
  loop do
    working_color = Hash[lab_color_a.map { |k,v| [k, v + t * lab_color_ab[k]] }]
    
    res = lab_to_rgb(working_color)
    
    
    t += dir * (1.0/60 * 0.5)
    
    pixels.each { |i| pixels[i] = res }
    pixels.update!
    pixels.update!
    
    dir = -dir if t > 1 || t < 0
    
    sleep 1.0/60
  end
end
