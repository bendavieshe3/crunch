# frozen_string_literal: true

require_relative "lib/crunch/version"

Gem::Specification.new do |spec|
  spec.name = "crunch"
  spec.version = Crunch::VERSION
  spec.authors = ["Ben Davies"]
  spec.email = ["ben@bendavies.dev"]

  spec.summary = "A CLI tool to concatenate text files for LLM context"
  spec.description = "Crunch is a simple CLI tool to concatenate text based files into a single file for easier communication of context to LLMs."
  spec.homepage = "https://github.com/bendavieshe3/crunch"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.glob(%w[
    lib/**/*.rb
    bin/*
    *.md
    *.txt
    *.gemspec
  ])
  spec.bindir = "bin"
  spec.executables = ["crunch"]
  spec.require_paths = ["lib"]

  # Runtime dependencies
  # Add any gems that your code needs to run
  # spec.add_dependency "example-gem", "~> 1.0"

  # Development dependencies
  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 1.21"
end