# frozen_string_literal: true

require "spec_helper"
require "minitest_to_rspec/cli"

module MinitestToRspec
  RSpec.describe CLI do
    let(:cli) { described_class.new([source, target]) }
    let(:source) { "spec/fixtures/01_trivial_assertion/in.rb" }
    let(:target) { "/dev/null" }

    before(:all) do
      # Tests require certain files to exist
      # http://pubs.opengroup.org/onlinepubs/000095399/basedefs/xbd_chap10.html
      unless File.exist?("/dev/null") && Dir.exist?("/tmp")
        fail "Tests require a POSIX OS"
      end
    end

    before(:each) do
      # Don't actually write target file
      allow(cli).to receive(:write_target)
    end

    describe ".new" do
      context "target omitted" do
        it "infers target" do
          cli = described_class.new(["test/fruit/banana_test.rb"])
          expect(cli.target).to eq("spec/fruit/banana_spec.rb")
        end
      end

      context "no arguments" do
        it "exits with status code E_USAGE" do
          # It also prints usage, but rspec `output` matcher only partially
          # works when combined with `raise_error(SystemExit)` matcher.
          expect {
            expect { described_class.new([]) }.to output.to_stderr
          }.to raise_error(SystemExit) { |e|
            expect(e.status).to eq(described_class::E_USAGE)
          }
        end
      end
    end

    describe "#run" do
      it "converts source to target" do
        expect(cli).to receive(:assert_file_does_not_exist)
        cli.run
      end

      it "catches MinitestToRspec::Error" do
        allow(cli).to receive(:assert_file_does_not_exist)
        allow(cli).to receive(:converter).and_raise(Error, "so sad")
        expect {
          expect { cli.run }.to output("Failed to convert: so sad").to_stderr
        }.to raise_error(SystemExit)
      end
    end

    describe "#assert_file_does_not_exist" do
      context "when file exists" do
        it "exits with code E_FILE_ALREADY_EXISTS" do
          expect {
            expect { cli.run }.to output(
              "File already exists: /dev/null"
            ).to_stderr
          }.to raise_error(SystemExit)
        end
      end
    end

    describe "#assert_file_exists" do
      context "when file does not exist" do
        let(:source) { "does_not_exist_3819e90182546cf5da27f193d0f3000164" }

        it "exits with code E_FILE_NOT_FOUND" do
          expect {
            expect { cli.run }.to output(
              "File not found: #{source}"
            ).to_stderr
          }.to raise_error(SystemExit)
        end
      end
    end

    describe "#ensure_target_directory" do
      context "when dir exists" do
        let(:target) { "/tmp/banana_spec.rb" }

        it "returns nil and does not call mkdir_p" do
          expect(FileUtils).to_not receive(:mkdir_p)
          cli.run
        end
      end

      context "when dir does not exist" do
        let(:target) {
          "/tmp/3819e90182546cf5da27f193d0f3000164/banana_spec.rb"
        }

        it "calls mkdir_p" do
          expect(FileUtils).to receive(:mkdir_p).with(
            "/tmp/3819e90182546cf5da27f193d0f3000164"
          )
          cli.run
        end
      end
    end
  end
end
