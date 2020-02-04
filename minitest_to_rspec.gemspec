# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'minitest_to_rspec/version'

Gem::Specification.new do |spec|
  spec.name = 'minitest_to_rspec'
  spec.version = MinitestToRspec.gem_version.to_s
  spec.executables << 'mt2rspec'
  spec.authors = ['Jared Beck']
  spec.email = ['jared@jaredbeck.com']

  spec.summary = 'Converts minitest files to rspec'
  spec.description = <<~EOS
    A command-line tool for converting minitest files to rspec.
  EOS
  spec.homepage = 'https://github.com/jaredbeck/minitest_to_rspec'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '>= 2.3.0'

  spec.add_runtime_dependency 'optimist', '~> 3.0'
  spec.add_runtime_dependency 'ruby2ruby', '~> 2.4.4'
  spec.add_runtime_dependency 'ruby_parser', '~> 3.11.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'byebug', '~> 11.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.79'
end
