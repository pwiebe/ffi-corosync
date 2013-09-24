# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ffi-corosync/version'

Gem::Specification.new do |spec|
  spec.name          = "ffi-corosync"
  spec.version       = Ffi::Corosync::VERSION
  spec.authors       = ["Philip Wiebe"]
  spec.email         = ["pwiebe_99@yahoo.com"]
  spec.description   = %q{A Ruby interface to the Corosync library}
  spec.summary       = %q{A Ruby interface to the Corosync library}
  spec.homepage      = "http://github.com/pwiebe/ffi-corosync"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ffi"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
