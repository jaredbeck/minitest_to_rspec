if ENV.key?('CODECLIMATE_REPO_TOKEN')
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'minitest_to_rspec'
require "pry"
require "pry-nav"
