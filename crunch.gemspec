# frozen_string_literal: true

Gem::Specification.new do |spec|
    spec.name          = "crunch"
    spec.version       = "0.1.0"
    spec.authors       = ["Ben Davies"]
    spec.email         = ["your.email@example.com"]
  
    spec.summary       = "CLI tool to concatenate text based files for LLM context"
    spec.description   = "Crunch is a simple CLI tool to concatenate text based files into a single file for easier communication of context to LLMs"
    spec.homepage      = "https://github.com/bendavieshe3/crunch"
    spec.license       = "MIT"
    spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")
  
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = spec.homepage
    spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  
    # Specify which files should be added to the gem when it is released.
    spec.files = Dir.glob(%w[
      lib/**/*.rb
      bin/*
      *.md
      LICENSE
    ])
    spec.bindir        = "bin"
    spec.executables   = ["crunch"]
    spec.require_paths = ["lib"]
  
    # Development dependencies
    spec.add_development_dependency "rspec", "~> 3.0"
    spec.add_development_dependency "rubocop", "~> 1.21"
  end