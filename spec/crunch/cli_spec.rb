# FILE: spec/crunch/cli_spec.rb
# frozen_string_literal: true

require "spec_helper"

RSpec.describe Crunch::CLI do
  let(:cli) { described_class.new }
  let(:test_dir) { "spec/fixtures/test_project" }
  
  before(:each) do
    FileUtils.rm_rf(test_dir)
    FileUtils.mkdir_p(test_dir)
  end

  after(:each) do
    FileUtils.rm_rf(test_dir)
    FileUtils.rm_f("test_output.txt")
  end
  
  describe ".parse_options" do
    it "sets default options when no arguments given" do
      options = described_class.parse_options([])
      expect(options[:source_path]).to be_nil
      expect(options[:output_file]).to be_nil
      expect(options[:verbose]).to be_nil
    end

    it "sets source path from argument" do
      options = described_class.parse_options(["/some/path"])
      expect(options[:source_path]).to eq("/some/path")
    end

    it "sets output file from -o option" do
      options = described_class.parse_options(["-o", "output.txt"])
      expect(options[:output_file]).to eq("output.txt")
    end

    it "sets verbose flag" do
      options = described_class.parse_options(["-v"])
      expect(options[:verbose]).to be true
    end
  end

  describe "#should_include_file?" do
    let(:cli) { described_class.new(source_path: test_dir) }

    context "with configuration files" do
      it "includes .gitignore" do
        File.write("#{test_dir}/.gitignore", "")
        file = Pathname.new("#{test_dir}/.gitignore")
        expect(cli.send(:should_include_file?, file)).to be true
      end

      it "includes .rubocop.yml" do
        File.write("#{test_dir}/.rubocop.yml", "")
        file = Pathname.new("#{test_dir}/.rubocop.yml")
        expect(cli.send(:should_include_file?, file)).to be true
      end

      it "includes .ruby-version" do
        File.write("#{test_dir}/.ruby-version", "")
        file = Pathname.new("#{test_dir}/.ruby-version")
        expect(cli.send(:should_include_file?, file)).to be true
      end

      it "includes CI configuration files" do
        File.write("#{test_dir}/.gitlab-ci.yml", "")
        file = Pathname.new("#{test_dir}/.gitlab-ci.yml")
        expect(cli.send(:should_include_file?, file)).to be true
      end
    end

    context "with sensitive files" do
      it "excludes .env files" do
        [".env", ".env.development", ".env.test", ".env.production"].each do |env_file|
          File.write("#{test_dir}/#{env_file}", "")
          file = Pathname.new("#{test_dir}/#{env_file}")
          expect(cli.send(:should_include_file?, file)).to be false
        end
      end

      it "excludes .rspec_status" do
        File.write("#{test_dir}/.rspec_status", "")
        file = Pathname.new("#{test_dir}/.rspec_status")
        expect(cli.send(:should_include_file?, file)).to be false
      end

      it "excludes editor temporary files" do
        [".file.swp", "file~", ".#file"].each do |temp_file|
          File.write("#{test_dir}/#{temp_file}", "")
          file = Pathname.new("#{test_dir}/#{temp_file}")
          expect(cli.send(:should_include_file?, file)).to be false
        end
      end
    end

    context "with nested configuration files" do
      before do
        FileUtils.mkdir_p("#{test_dir}/.github/workflows")
        File.write("#{test_dir}/.github/workflows/test.yml", "name: Test")
      end

      it "includes GitHub workflow files" do
        file = Pathname.new("#{test_dir}/.github/workflows/test.yml")
        expect(cli.send(:should_include_file?, file)).to be true
      end
    end
  end

  describe "#excluded_directory?" do
    let(:cli) { described_class.new(source_path: test_dir) }

    def create_and_test_directory(dir_name)
      full_path = "#{test_dir}/#{dir_name}"
      FileUtils.mkdir_p(full_path)
      Pathname.new(full_path)
    end

    it "excludes version control directories" do
      [".git", ".svn", ".hg"].each do |vcs_dir|
        dir = create_and_test_directory(vcs_dir)
        expect(cli.send(:excluded_directory?, dir)).to(
          be(true),
          "Expected #{vcs_dir} to be excluded"
        )
      end
    end

    it "excludes dependency directories" do
      ["node_modules", "vendor", "bundle"].each do |dep_dir|
        dir = create_and_test_directory(dep_dir)
        expect(cli.send(:excluded_directory?, dir)).to(
          be(true),
          "Expected #{dep_dir} to be excluded"
        )
      end
    end

    it "excludes build and temporary directories" do
      ["coverage", "tmp", "log"].each do |build_dir|
        dir = create_and_test_directory(build_dir)
        expect(cli.send(:excluded_directory?, dir)).to(
          be(true),
          "Expected #{build_dir} to be excluded"
        )
      end
    end

    it "includes regular project directories" do
      ["src", "lib", "app", "config"].each do |project_dir|
        dir = create_and_test_directory(project_dir)
        expect(cli.send(:excluded_directory?, dir)).to(
          be(false),
          "Expected #{project_dir} to be included"
        )
      end
    end
  end

  describe "#run with various file types" do
    before do
      FileUtils.rm_rf(test_dir)
      FileUtils.mkdir_p("#{test_dir}/config")
      FileUtils.mkdir_p("#{test_dir}/.github/workflows")
      
      # Create test files
      File.write("#{test_dir}/.gitignore", "node_modules/\n*.log")
      File.write("#{test_dir}/.env", "SECRET_KEY=test")
      File.write("#{test_dir}/config/database.yml", "development:\n  database: test")
      File.write("#{test_dir}/.github/workflows/test.yml", "name: Test\non: push")
      File.write("#{test_dir}/.rspec_status", "..FFF")
    end

    it "processes the correct files" do
      cli = described_class.new(
        source_path: test_dir,
        output_file: "test_output.txt",
        verbose: true
      )
      
      # Capture stdout to verify processed files
      output = StringIO.new
      $stdout = output
      cli.run
      $stdout = STDOUT
      
      output_content = File.read("test_output.txt")
      
      # Check included files
      expect(output_content).to include("=== BEGIN .gitignore ===")
      expect(output_content).to include("=== BEGIN .github/workflows/test.yml ===")
      expect(output_content).to include("=== BEGIN config/database.yml ===")
      
      # Check excluded files
      expect(output_content).not_to include("=== BEGIN .env ===")
      expect(output_content).not_to include("=== BEGIN .rspec_status ===")
      
      # Check stats output
      expect(output.string).to include("Total files processed:")
      expect(output.string).to include("Total size:")
    end
  end
end