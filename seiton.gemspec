# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'seiton/version'

Gem::Specification.new do |spec|
  spec.name          = "seiton"
  spec.version       = Seiton::VERSION
  spec.authors       = ["inokappa"]
  spec.email         = ["inokara@gmail.com"]

  spec.summary       = %q{The seiton (整頓) tidies up your AWS Resources.}
  spec.description   = %q{The seiton (整頓) tidies up your AWS Resources.}
  spec.homepage      = "https://github.com/oreno-tools/seiton"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|check)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_dependency "rake"
  spec.add_dependency 'thor'
  spec.add_dependency 'aws-sdk'
  spec.add_dependency 'terminal-table'
  spec.add_dependency 'awspec'
  spec.add_dependency 'highline'
end
