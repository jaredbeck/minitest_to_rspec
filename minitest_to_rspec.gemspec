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
A command-line tool for converting minitest files to rspec.
  EOS
  spec.homepage = "https://github.com/jaredbeck/minitest_to_rspec"
  spec.license = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = ">= 2.2.0"

  spec.add_runtime_dependency "ruby_parser", "~> 3.8"
  spec.add_runtime_dependency "ruby2ruby", "~> 2.3"
  spec.add_runtime_dependency "trollop", "~> 2.1"

  # Temporary runtime dependency. It seems there were breaking changes in
  # sexp_processor between 4.7 and 4.10. When we have adapted to these breaking
  # changes, we can lift this constraint.
  # https://github.com/jaredbeck/minitest_to_rspec/issues/4
  spec.add_runtime_dependency "sexp_processor", "< 4.8"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "byebug", "~> 9.1"
  spec.add_development_dependency "rake", "~> 12.1"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rubocop", "~> 0.42.0"
end
