# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virtfs/xfs/version'

Gem::Specification.new do |spec|
  spec.name          = "virtfs-xfs"
  spec.version       = VirtFS::XFS::VERSION
  spec.authors       = ["ManageIQ Developers"]

  spec.summary       = %q{An ext4 based filesystem module for VirtFS}
  spec.description   = %q{An ext4 based filesystem module for VirtFS}
  spec.homepage      = "https://github.com/ManageIQ/virtfs-xfs"
  spec.license       = "Apache 2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency("uuidtools", "~> 2.2")

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "manageiq-style"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec",         "~> 3.0"
end
