# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest_to_rspec/version'

Gem::Specification.new do |spec|
  spec.name = "minitest_to_rspec"
  spec.version = MinitestToRspec::VERSION
  spec.executables << 'mt2rspec'
  spec.authors = ["Jared Beck"]
  spec.email = ["jared@jaredbeck.com"]

  spec.summary = "Converts minitest files to rspec"
  spec.description = <<-EOS
A command-line tool for converting minitest files to rspec.  Uses
Ryan Davis' excellent libraries: ruby_parser, sexp_processor, and
ruby2ruby.
  EOS
  spec.homepage = "https://github.com/jaredbeck/minitest_to_rspec"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.0.0"

  spec.add_runtime_dependency "ruby_parser", "~> 3.7"
  spec.add_runtime_dependency "sexp2ruby", "~> 0.0.3"
  spec.add_runtime_dependency "trollop", "~> 2.1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "cane", "~> 2.6"
  spec.add_development_dependency "codeclimate-test-reporter", "~> 0.4.7"
  spec.add_development_dependency "rake", "~> 10.4"
  spec.add_development_dependency "rspec", "~> 3.2"
  spec.add_development_dependency "pry", "~> 0.10.1"
  spec.add_development_dependency "pry-nav", "~> 0.2.4"
end
