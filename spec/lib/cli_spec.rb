require "spec_helper"
require "minitest_to_rspec/cli"

module MinitestToRspec
  RSpec.describe CLI do
    describe ".new" do
      context "target omitted" do
        it "infers target" do
          argv = ["test/fruit/banana_test.rb"]
          cli = described_class.new(argv)
          expect(cli.target).to eq("spec/fruit/banana_spec.rb")
        end
      end
    end
  end
end
