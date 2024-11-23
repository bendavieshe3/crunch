# Crunch

Crunch is a simple CLI tool to concatenate text based files into a single file for easier communiction of context to LLMs. 

## How Crunch works

### What is in the output file?

* Automatically includes and excludes files based on general rules and can leverage a .gitignore file to understand what files to ignore.
    * source code files such as .py, .js, .ts, .go, .rs, .swift, .java, .kt, .cpp, .c, .h, .hpp, .hs, .scala, .vb, .php, .rb, .rs, .swift, .java, .kt, .cpp, .c, .h, .hpp, .hs, .scala, .vb, .php, .rb, .sh, .lua, .pl, .sql, etc. are included by default
    * Derived files are excluded by default
    * Certain standard files by operating system are excluded by default (like .DS_Store on macOS)
    * Certain standard development files without an extension are known and included: Rakefile, Gemfile, package.json, etc.
    * Hidden directories for source control are also known and excluded by default: .git, .svn, .hg, .bzr
* Intelligently adds breaks within the concatenated text to communicate the file and folder structure to the LLM
* Creates its concatenated output with a standard txt extension. 
* By default, includes a representation of the overall folder structure at the top of the file to help with context.

### What is output to the console?
* In addition to the output file, it will also print the number of files included and the total size of the output file to the console.
* If the verbose flag is provided, it will print the file paths of the files that were included and include a summary of the total file size contributed by each folder and file type.

### Use cases:

* run against a obsidian vault (or folder within a vault) to create a single file that can be used as context for an LLM (collecting markdown files, images, and potentially other file types)
* run against a development project to create a single file with relevant source code without the sensitive information stored in dotfiles etc.

## Usage: 

Crunch is available anywhere on the shell once it is has been installed

Use default settings to crunch the current directory:
```
crunch .
```

Use default settings to crunch the current directory and save the output to a file called `context.txt`:
```
crunch . -o context.txt
```

Use default settings to crunch a specific subfolder:

```
crunch ./my-subfolder
```

Override the default settings to exclude all files with the .md extension:

```
crunch . --exclude "*.md"
```

Override the default settings to include all files with the .md extension:

```
crunch . --include "*.md"
```

Use the verbose flag to get more information about the output file:

```
crunch . -v
```

## Installation

## Contributing

Don't contribute.

## License

MIT
