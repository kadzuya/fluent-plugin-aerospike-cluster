# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "fluent-plugin-aerospike-cluster"
  spec.version       = "0.0.2"
  spec.authors       = ["kadzuya"]
  spec.email         = ["kadzuya@gmail.com"]

  spec.summary       = %q{fluent plugin to insert Aerospike.}
  spec.description   = %q{fluent plugin to insert Aerospike.}
  spec.homepage      = "http://github.com/kadzuya/fluent-plugin-aerospike-cluster"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "fluentd"
  spec.add_runtime_dependency "aerospike", '>= 1.0.0', '< 2.0.0'
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
