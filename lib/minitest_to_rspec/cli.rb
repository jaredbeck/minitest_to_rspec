require "minitest_to_rspec"
require "trollop"

# https://github.com/ManageIQ/trollop/issues/57
module Trollop
  def self.educate_without_exiting
    @last_parser.educate($stderr)
  end
end

module MinitestToRspec
  class CLI
    E_USAGE               = 1.freeze
    E_FILE_NOT_FOUND      = 2.freeze
    E_FILE_ALREADY_EXISTS = 3.freeze
    E_CONVERT_FAIL        = 4.freeze

    BANNER = <<EOS.freeze
Usage: mt2rspec --rails source_file [target_file]

Reads source_file, writes target_file.  If target_file is omitted,
its location will be inferred.  For example, test/fruit/banana_test.rb
implies spec/fruit/banana_spec.rb.

Options:
EOS

    OPT_RAILS = <<EOS.gsub(/\n/, " ").freeze
Requires rails_helper instead of spec_helper.
Passes :type metadatum to RSpec.describe.
EOS

    attr_reader :rails, :source, :target

    def initialize(args)
      opts = Trollop::options(args) do
        version MinitestToRspec::VERSION
        banner BANNER
        opt :rails, OPT_RAILS, short: :none
      end

      @rails = opts[:rails]
      case args.length
      when 2
        @source, @target = args
      when 1
        @source = args[0]
        @target = infer_target_from @source
      else
        Trollop.educate_without_exiting
        exit(E_USAGE)
      end
    end

    def run
      assert_file_exists(source)
      assert_file_does_not_exist(target)
      write_target(converter.convert(read_source))
    rescue Error => e
      $stderr.puts "Failed to convert: #{e}"
      exit E_CONVERT_FAIL
    end

    private

    def assert_file_exists(file)
      unless File.exist?(file)
        $stderr.puts "File not found: #{file}"
        exit(E_FILE_NOT_FOUND)
      end
    end

    def assert_file_does_not_exist(file)
      if File.exist?(file)
        $stderr.puts "File already exists: #{file}"
        exit(E_FILE_ALREADY_EXISTS)
      end
    end

    def converter
      Converter.new(rails: rails)
    end

    def infer_target_from(source)
      source.
        gsub(/\Atest/, "spec").
        gsub(/_test.rb\Z/, "_spec.rb")
    end

    def read_source
      File.read(source)
    end

    def write_target(str)
      File.write(target, str)
    end
  end
end
