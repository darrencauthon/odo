# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'odo/version'

Gem::Specification.new do |spec|
  spec.name          = "odo"
  spec.version       = Odo::VERSION
  spec.authors       = ["Darren Cauthon"]
  spec.email         = ["darren@cauthon.com"]
  spec.summary       = %q{Turn a static website or template into a web application.}
  spec.description   = %q{Turns a static site into a web application.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"

  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "uuid"
  spec.add_runtime_dependency "image_scraper"
end
