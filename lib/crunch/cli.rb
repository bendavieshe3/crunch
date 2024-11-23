# FILE: lib/crunch/cli.rb
#!/usr/bin/env ruby
require 'optparse'
require 'pathname'
require 'fileutils'

module Crunch
  class CLI 
    DEFAULT_INCLUDE_EXTENSIONS = %w[
      .py .js .ts .go .rs .swift .java .kt .cpp .c .h .hpp 
      .hs .scala .vb .php .rb .rs .swift .kt .sh .lua .pl .sql .md
      .gemspec .yml .yaml
    ].freeze

    # Configuration files that should be included
    DEFAULT_KNOWN_FILES = %w[
      Rakefile Gemfile package.json Dockerfile Makefile
      .gitignore .rubocop.yml .rspec .ruby-version .ruby-gemset
      .eslintrc .prettierrc .babelrc .editorconfig
      .gitlab-ci.yml .github/workflows/*.yml
    ].freeze

    # Directories that should always be excluded
    EXCLUDED_DIRECTORIES = %w[
      .git .svn .hg .bzr node_modules vendor bundle
      coverage tmp log .bundle
    ].freeze

    # Files that should always be excluded (including sensitive dotfiles)
    EXCLUDED_FILES = %w[
      .DS_Store Thumbs.db 
      .env .env.* .env.development .env.test .env.production
      .rspec_status 
      .byebug_history
      *.log
      *.swp .*.swp
      *~ 
    ].freeze

    def self.start(args = ARGV)
      options = parse_options(args)
      new(options).run
    end

    def self.parse_options(args)
      options = {}
      OptionParser.new do |opts|
        opts.banner = "Usage: crunch [directory] [options]"

        opts.on("-o", "--output FILENAME", "Output filename") do |filename|
          options[:output_file] = filename
        end

        opts.on("-v", "--verbose", "Verbose output") do
          options[:verbose] = true
        end

        opts.on("--include PATTERN", "Include file pattern") do |pattern|
          options[:include] ||= []
          options[:include] << pattern
        end

        opts.on("--exclude PATTERN", "Exclude file pattern") do |pattern|
          options[:exclude] ||= []
          options[:exclude] << pattern
        end

        opts.on("-h", "--help", "Show this help message") do
          puts opts
          exit
        end
      end.parse!(args)

      options[:source_path] = args[0] if args[0]
      options
    end

    def initialize(options = {})
      @source_path = Pathname.new(options[:source_path] || '.')
      @output_file = options[:output_file] || 'crunch_output.txt'
      @verbose = options[:verbose] || false
      @include_patterns = Array(options[:include]) if options[:include]
      @exclude_patterns = Array(options[:exclude]) if options[:exclude]
      @file_stats = { total_files: 0, total_size: 0, by_folder: {}, by_extension: {} }
    end

    def run
      content = []
      content << generate_folder_structure
      content << "\n--- BEGIN CONCATENATED FILES ---\n\n"
      
      process_directory(@source_path, content)
      
      write_output(content.join)
      print_stats
    end

    private

    def generate_folder_structure
      structure = ["# Folder Structure\n\n"]
      generate_tree(@source_path, structure, "", true)
      structure.join
    end

    def generate_tree(path, output, prefix = "", root = false)
      return if excluded_directory?(path)

      unless root
        name = path.basename
        output << "#{prefix}#{prefix.empty? ? '' : '└── '}#{name}\n"
        prefix = prefix.empty? ? '    ' : prefix + '    '
      end

      path.children.sort_by { |p| [p.directory? ? 0 : 1, p.basename.to_s] }.each do |child|
        if child.directory?
          generate_tree(child, output, prefix) unless excluded_directory?(child)
        else
          output << "#{prefix}#{child.basename}\n" if should_include_file?(child)
        end
      end
    end

    def process_directory(path, content)
      path.children.sort.each do |entry|
        next if excluded_directory?(entry)

        if entry.directory?
          process_directory(entry, content)
        elsif should_include_file?(entry)
          process_file(entry, content)
        end
      end
    end

    def process_file(file, content)
      relative_path = file.relative_path_from(@source_path)
      file_content = File.read(file)
      file_size = File.size(file)

      update_stats(file, file_size)

      content << "=== BEGIN #{relative_path} ===\n"
      content << file_content
      content << "\n=== END #{relative_path} ===\n\n"
    end

    def should_include_file?(file)
      basename = file.basename.to_s
      relative_path = file.relative_path_from(@source_path).to_s
      
      # Check explicit exclusions first
      return false if file_matches_any?(relative_path, EXCLUDED_FILES)
      
      # Check user-provided patterns
      if @include_patterns
        return @include_patterns.any? { |pattern| File.fnmatch(pattern, relative_path) }
      end

      if @exclude_patterns
        return false if @exclude_patterns.any? { |pattern| File.fnmatch(pattern, relative_path) }
      end

      # Check if it's a known configuration file
      return true if DEFAULT_KNOWN_FILES.any? { |pattern| File.fnmatch(pattern, relative_path, File::FNM_PATHNAME) }

      # Check file extension
      extension = file.extname.downcase
      DEFAULT_INCLUDE_EXTENSIONS.include?(extension)
    end

    def file_matches_any?(path, patterns)
      patterns.any? do |pattern|
        if pattern.include?('*') || pattern.include?('/')
          File.fnmatch(pattern, path, File::FNM_PATHNAME)
        else
          File.basename(path) == pattern
        end
      end
    end

    def excluded_directory?(path)
      return false unless path.directory?
      
      relative_path = path.relative_path_from(@source_path).to_s
      
      EXCLUDED_DIRECTORIES.any? do |pattern|
        if pattern.include?('/')
          # Handle nested patterns
          File.fnmatch(pattern, relative_path, File::FNM_PATHNAME)
        else
          # Handle top-level directory matches
          parts = relative_path.split('/')
          parts.any? { |part| part == pattern }
        end
      end
    end

    def update_stats(file, size)
      @file_stats[:total_files] += 1
      @file_stats[:total_size] += size
      
      # Update folder statistics
      folder = file.dirname.relative_path_from(@source_path).to_s
      folder = '.' if folder.empty?
      @file_stats[:by_folder][folder] ||= 0
      @file_stats[:by_folder][folder] += size

      # Update extension statistics
      ext = file.extname.downcase
      ext = 'no_extension' if ext.empty?
      @file_stats[:by_extension][ext] ||= 0
      @file_stats[:by_extension][ext] += size
    end

    def write_output(content)
      File.write(@output_file, content)
    end

    def print_stats
      puts "\nCrunch completed successfully!"
      puts "Total files processed: #{@file_stats[:total_files]}"
      puts "Total size: #{format_size(@file_stats[:total_size])}"
      puts "Output written to: #{@output_file}"

      if @verbose
        puts "\nSize by folder:"
        @file_stats[:by_folder].sort_by { |_, size| -size }.each do |folder, size|
          puts "  #{folder}: #{format_size(size)}"
        end

        puts "\nSize by extension:"
        @file_stats[:by_extension].sort_by { |_, size| -size }.each do |ext, size|
          puts "  #{ext}: #{format_size(size)}"
        end
      end
    end

    def format_size(size)
      units = ['B', 'KB', 'MB', 'GB']
      unit_index = 0
      
      while size >= 1024 && unit_index < units.length - 1
        size /= 1024.0
        unit_index += 1
      end

      format("%.2f %s", size, units[unit_index])
    end
  end
end