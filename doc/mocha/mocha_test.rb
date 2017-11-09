# frozen_string_literal: true

require 'rubygems'
gem 'mocha'
require 'minitest/unit'
require 'mocha/mini_test'
require 'minitest/autorun'

# Reverse engineering mocha, to clarify some things missing in the mocha docs.
class TestDerp < Minitest::Test
  def test_expects_return_value
    x = Object.new
    x.define_singleton_method(:y) { :z } # this won't get called
    x.expects(:y)
    assert_nil x.y
    # passes
  end

  def test_stubs_only
    x = Object.new
    x.stubs(:y)
    # passes
  end

  def test_stubs_returns
    x = Object.new
    x.stubs(:y).returns(:z)
    # passes
  end

  def test_stubs_once
    x = Object.new
    x.stubs(:y).once
    # fails: expected exactly once, not yet invoked
  end

  def test_stubs_twice
    x = Object.new
    x.stubs(:y).twice
    # fails: expected exactly twice, not yet invoked
  end

  def test_stubs_return_value
    x = Object.new
    x.define_singleton_method(:y) { :z } # this won't get called
    x.stubs(:y)
    assert_nil x.y
    # passes
  end
end
