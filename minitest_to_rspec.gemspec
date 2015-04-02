# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest_to_rspec/version'

Gem::Specification.new do |spec|
  spec.name = "minitest_to_rspec"
  spec.version = MinitestToRspec::VERSION
  spec.authors = ["Jared Beck"]
  spec.email = ["jared@jaredbeck.com"]

  spec.summary = "Converts minitest files to rspec"
  spec.homepage = "https://github.com/jaredbeck/minitest_to_rspec"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ruby_parser"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "cane"
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "ruby2ruby"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
end
