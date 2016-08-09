require 'cane/rake_task'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

desc 'Check quality metrics'
Cane::RakeTask.new(:quality) do |cane|
  cane.max_violations = 0
  cane.abc_glob = 'lib/**/*.rb'
  cane.abc_max = 10
  cane.no_doc = true
  cane.style_glob = 'lib/**/*.rb'
  cane.style_measure = 80
end

task(:spec).clear
RSpec::Core::RakeTask.new(:spec) do |t|
  t.verbose = false
end

# Default task: lint then test
task default: [] # in case it hasn't been set
Rake::Task[:default].clear
task default: [:rubocop, :quality, :spec]
