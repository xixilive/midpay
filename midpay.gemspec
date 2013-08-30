# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'midpay/version'

Gem::Specification.new do |spec|
  spec.name          = "midpay"
  spec.version       = Midpay::VERSION
  spec.authors       = ["xixilive"]
  spec.email         = ["xixilive@gmail.com"]
  spec.description   = %q{A Rack Middleware for E-Commerce Payment Base-Strategy}
  spec.summary       = %q{A Rack Middleware for E-Commerce Payment Base-Strategy}
  spec.homepage      = "https://github.com/xixilive/midpay"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'hashie'
  spec.add_dependency 'rack', ">= 1.4"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
