require 'spec_helper'

describe MinitestToRspec do
  describe 'VERSION' do
    it 'returns a String' do
      expect(described_class::VERSION).to be_a(::String)
    end
  end

  describe '.gem_version' do
    it 'returns a Gem::Version that corresponds to VERSION' do
      expect(described_class.gem_version).to eq(
        ::Gem::Version.new(described_class::VERSION)
      )
    end
  end
end
