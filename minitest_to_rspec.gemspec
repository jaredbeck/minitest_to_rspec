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

  spec.add_runtime_dependency 'ruby2ruby', '~> 2.3'
  spec.add_runtime_dependency 'ruby_parser', '~> 3.8'
  spec.add_runtime_dependency 'trollop', '~> 2.1'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'byebug', '~> 9.1'
  spec.add_development_dependency 'rake', '~> 12.1'
  spec.add_development_dependency 'rspec', '~> 3.5'
  spec.add_development_dependency 'rubocop', '~> 0.51.0'
end
