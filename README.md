# Crunch

Crunch is a simple CLI tool to concatenate text based files into a single file for easier communication of context to LLMs. 

## How Crunch works

### What is in the output file?

* Automatically includes and excludes files based on general rules and can leverage a .gitignore file to understand what files to ignore.
    * source code files such as .py, .js, .ts, .go, .rs, .swift, .java, .kt, .cpp, .c, .h, .hpp, .hs, .scala, .vb, .php, .rb, .rs, .swift, .java, .kt, .cpp, .c, .h, .hpp, .hs, .scala, .vb, .php, .rb, .sh, .lua, .pl, .sql, etc. are included by default
    * Derived files are excluded by default
    * Certain standard files by operating system are excluded by default (like .DS_Store on macOS)
    * Certain standard files without an extension are known and included: Rakefile, Gemfile, package.json, etc.
    * Hidden directories for source control are also known and excluded by default: .git, .svn, .hg, .bzr
* Intelligently adds breaks within the concatenated text to communicate the file and folder structure to the LLM
* Creates its concatenated output with a standard txt extension
* By default, includes a representation of the overall folder structure at the top of the file to help with context

### What is output to the console?
* In addition to the output file, it will also print the number of files included and the total size of the output file to the console
* If the verbose flag is provided, it will print the file paths of the files that were included and include a summary of the total file size contributed by each folder and file type

## Installation

### As a user

```bash
gem install crunch
```

### For development

1. Clone the repository:
```bash
git clone https://github.com/yourusername/crunch.git
cd crunch
```

2. Install dependencies:
```bash
bundle install
```

3. Run the development version:
```bash
bundle exec bin/crunch
```

## Development

### Project Structure

```
bin/
  └── crunch           # Executable file
lib/
  └── crunch/
      ├── cli.rb       # Main CLI implementation
      └── version.rb   # Version information
  └── crunch.rb        # Main require file
spec/                  # Test files
Gemfile                # Dependencies
gemspec                # Gem specification
README.md             
```

### Running Tests

```bash
bundle exec rspec
```

### Building the Gem

1. Update the version number in `lib/crunch/version.rb`
2. Build the gem:
```bash
gem build crunch.gemspec
```
3. Install the gem locally for testing:
```bash
gem install ./crunch-0.1.0.gem
```

### Usage Examples

Use default settings to crunch the current directory:
```bash
crunch .
```

Use default settings to crunch the current directory and save the output to a file called `context.txt`:
```bash
crunch . -o context.txt
```

Use default settings to crunch a specific subfolder:
```bash
crunch ./my-subfolder
```

Override the default settings to exclude all files with the .md extension:
```bash
crunch . --exclude "*.md"
```

Override the default settings to include all files with the .md extension:
```bash
crunch . --include "*.md"
```

Use the verbose flag to get more information about the output file:
```bash
crunch . -v
```

### Command Line Options

```
Usage: crunch [directory] [options]
    -o, --output FILENAME            Output filename
    -v, --verbose                    Verbose output
        --include PATTERN           Include file pattern
        --exclude PATTERN           Exclude file pattern
    -h, --help                      Show this help message
```

## Release Process

1. Update the version number in `version.rb`
2. Update CHANGELOG.md with the changes
3. Commit the changes:
```bash
git commit -am "Release version X.Y.Z"
```
4. Create a tag:
```bash
git tag -a vX.Y.Z -m "Version X.Y.Z"
```
5. Push the changes and tags:
```bash
git push origin main --tags
```
6. Build and push the gem:
```bash
gem build crunch.gemspec
gem push crunch-X.Y.Z.gem
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Make your changes and ensure all tests pass
5. Commit your changes (`git commit -am 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Create a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).