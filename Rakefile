require 'cane/rake_task'
require 'rspec/core/rake_task'

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

task :default => [:quality, :spec]
