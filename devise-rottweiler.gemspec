# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'devise/rottweiler/version'

Gem::Specification.new do |spec|
  spec.name          = "devise-rottweiler"
  spec.version       = Devise::Rottweiler::VERSION
  spec.authors       = ["Georgi Martsenkov"]
  spec.email         = ["g.martsenkov@gmail.com"]

  spec.summary       = %q{Rottweiler devise extension.}
  spec.description   = %q{Rottweiler devise extension}
  spec.homepage      = "http://localhost:3000"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_runtime_dependency "httparty"
  spec.add_runtime_dependency "rottweiler-client"
  spec.add_runtime_dependency(%q<devise>, ["=3.5.1"])
  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
