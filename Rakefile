# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

task(:spec).clear
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

# Default task: lint then test
task default: [] # in case it hasn't been set
Rake::Task[:default].clear
task default: %i[rubocop spec]
