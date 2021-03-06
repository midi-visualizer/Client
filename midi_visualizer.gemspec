lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'midi_visualizer/version'

Gem::Specification.new do |spec|
  spec.name          = 'midi_visualizer'
  spec.version       = MIDIVisualizer::VERSION
  spec.authors       = ['Sebastian Lindberg']
  spec.email         = ['seb.lindberg@gmail.com']

  spec.summary       = 'Client code for the MIDI Visualizer project.'
  spec.description   = ''
  spec.homepage      = 'https://github.com'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the
  # 'allowed_push_host' to allow pushing to a single host or delete this section
  # to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = ''
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',  '~> 1.16'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'rake',     '~> 10.0'

  spec.add_dependency 'color',      '~> 1.8'
  spec.add_dependency 'highline',   '~> 1.7'
  spec.add_dependency 'serialport', '~> 1.3'
  spec.add_dependency 'thread',     '~> 0.2'
  spec.add_dependency 'unimidi',    '~> 0.4'

  spec.add_dependency 'midi_visualizer-interface-simulator', '~> 0.1'
end
