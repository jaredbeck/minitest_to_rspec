# frozen_string_literal: true

require 'spec_helper'

describe MinitestToRspec do
  describe '.gem_version' do
    it 'returns a Gem::Version' do
      expect(described_class.gem_version).to be_a(::Gem::Version)
    end
  end
end
