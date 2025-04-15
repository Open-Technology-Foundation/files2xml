# files2xml

Convert files to XML representation with metadata and content.

## Overview

`files2xml` is a Bash utility that creates an XML representation of files, including metadata and content. It's designed for archiving, documentation, or data transfer where a self-contained XML format is useful.

Features:
- Handles both text and binary files
- Text files are embedded as CDATA sections
- Binary files are base64-encoded
- Includes file metadata (name, type, size, modification time)
- Outputs to stdout for flexible pipeline usage
- Proper XML escaping for special characters

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
files2xml [OPTIONS] FILE [FILE ...]
```

### Arguments
- `FILE` - One or more files to include in the XML

### Options
- `-m, --max-file-size SIZE` - Set maximum file size (default: 1GB)
- `-v, --verbose` - Increase verbosity
- `-q, --quiet` - Suppress all messages
- `-V, --version` - Show version information
- `-h, --help` - Show help message

### Examples

Basic usage with output redirection:
```bash
files2xml file1.txt file2.pdf > files.xml
```

Process multiple files with find:
```bash
files2xml $(find . -name "*.py") > output.xml
```

Use with xargs for many files:
```bash
find . -name "*.log" | xargs files2xml > logs.xml
```

Process and compress output:
```bash
files2xml config.json README.md | gzip > backup.xml.gz
```

Use with grep to filter XML:
```bash
files2xml *.conf | grep -A10 "<file>" | less
```

Extract just the filenames:
```bash
files2xml -q *.py | grep -oP '<n>\K[^<]+'
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

## Notes

- Files larger than 1GB are skipped by default
- Common text extensions (.md, .txt, etc.) are forced to be treated as text files
- Symlinks are resolved to their target files
- Outputs to stdout for pipeline usage
- Use redirection (>) to save to a file

## Use in Scripts

When sourced in another script:
```bash
source files2xml
files_to_xml file1.txt file2.txt | process_xml
```

## Requirements

- Bash 4.0+
- Standard Unix utilities: basename, file, stat, date, sed, base64, readlink, numfmt

## License

[GPL-3 License](LICENSE)
