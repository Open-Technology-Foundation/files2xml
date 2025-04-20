# files2xml

Convert files to XML representation with metadata and content.

## Overview

`files2xml` is a Bash utility that creates an XML representation of files, including metadata and content. It's designed for archiving, documentation, or data transfer where a self-contained XML format is useful.

Features:
- Automatically detects binary vs text files using MIME encoding
- Text files are embedded as CDATA sections with proper escaping
- Binary files are base64-encoded
- Includes file metadata (name, type, size, modification time)
- Git repository integration to process tracked files
- Custom file ignore patterns
- Outputs to stdout for flexible pipeline usage
- Full XML escaping for paths and filenames

## Installation

```bash
# Clone the repository (if applicable)
git clone https://github.com/yourusername/files2xml.git

# Make the script executable
chmod +x files2xml

# Optionally, move to a directory in your PATH
sudo cp files2xml /usr/local/bin/
```

## Usage

```
files2xml [OPTIONS] [FILE ...]
```

### Arguments
- `FILE` - One or more files to include in the XML (optional if --gitdir is used)

### Options
- `-m, --max-file-size SIZE` - Set maximum file size (default: 1GB)
- `-g, --gitdir DIR` - Include files from git repository (can be used multiple times)
- `-i, --ignore PATTERN` - Add glob pattern to ignore list (can be used multiple times)
  - Default patterns: `'*.mp*' '~*' '*~' '*.bak' '*.log' '*.old' '*LI*'`
  - Use `-i ""` to clear the default patterns
- `-v, --verbose` - Increase verbosity
- `-q, --quiet` - Suppress all messages
- `-V, --version` - Show version information
- `-h, --help` - Show help message

### Examples

Basic usage with output redirection:
```bash
files2xml file1.txt file2.pdf > files.xml
```

Include git repository files:
```bash
files2xml --gitdir /path/to/repo > repo_files.xml
```

Combine multiple git repositories and regular files:
```bash
files2xml --gitdir /path/to/repo1 --gitdir /path/to/repo2 additional_file.txt > combined.xml
```

Specify custom ignore patterns (adds to default patterns):
```bash
files2xml --ignore "*.tmp" --ignore "*.cache" dir/*.py > files.xml
```

Clear default ignore patterns and set custom ones:
```bash
files2xml --ignore "" --ignore "*.tmp" --gitdir /path/to/repo > files.xml
```

Process multiple files with find:
```bash
find . -type f -name "*.py" -exec files2xml {} + > output.xml
```

Use with XML tools like xmlstarlet:
```bash
files2xml *.sh | xmlstarlet sel -t -v "//file[type='text/x-shellscript']/n"
```

## XML Format

The script generates XML with the following structure:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Files>
  <file>
    <fqfn>/absolute/path/to/file.txt</fqfn>
    <n>file.txt</n>
    <type>text/plain</type>
    <size>1234</size>
    <modified>2025-04-15T10:30:45</modified>
    <content><![CDATA[File content goes here...]]></content>
  </file>
  <file>
    <fqfn>/absolute/path/to/image.png</fqfn>
    <n>image.png</n>
    <type>image/png</type>
    <size>5678</size>
    <modified>2025-04-15T11:25:30</modified>
    <content encoding="base64">base64encodedcontent...</content>
  </file>
</Files>
```

## Implementation Details

- **Text vs Binary detection**: Uses `file --mime-encoding` to determine if a file should be treated as text or binary
- **Git integration**: Can process files tracked in git repositories using `git ls-files`
- **Custom ignore patterns**: Supports glob patterns to exclude files
- **Error handling**: Provides detailed error messages and continues processing when individual files fail
- **XML escaping**: All file paths and names are properly escaped to ensure valid XML
- **Size limiting**: Files exceeding the maximum size limit are skipped with appropriate messaging
- **Symlink resolution**: Symlinks are resolved to their actual target files
- **CDATA escaping**: Properly handles CDATA end sequences (`]]>`) in text files

## Use in Scripts

When sourced in another script:
```bash
source files2xml
files_to_xml file1.txt file2.txt | process_xml
```

## Requirements

- Bash 4.0+
- Git (for --gitdir functionality)
- Standard Unix utilities: basename, file, stat, date, sed, base64, readlink, numfmt, getopt

## License

[GPL-3 License](LICENSE)