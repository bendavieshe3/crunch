# frozen_string_literal: true

require "spec_helper"

RSpec.describe Crunch::CLI do
    let(:cli) { described_class.new }
    
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
  
    describe "#run" do
      let(:test_dir) { "spec/fixtures/test_project" }
      
      before do
        FileUtils.mkdir_p(test_dir)
        File.write("#{test_dir}/test.rb", "puts 'hello'")
      end
  
      after do
        FileUtils.rm_rf(test_dir)
      end
  
      it "creates output file" do
        cli = described_class.new(source_path: test_dir, output_file: "test_output.txt")
        cli.run
        expect(File.exist?("test_output.txt")).to be true
        FileUtils.rm("test_output.txt")
      end
    end
  end