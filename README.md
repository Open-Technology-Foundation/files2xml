# files2xml

Convert files to XML representation with metadata and content.

[![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## Overview

`files2xml` is a robust Bash utility that creates standardized XML representations of files, including their metadata and content. It automatically handles both text and binary files appropriately, embedding text content within CDATA sections and encoding binary content as base64. Designed for archiving, documentation, data transfer, or integration with XML processing pipelines.

## Features

- **Intelligent Content Handling**: 
  - Automatically detects binary vs text files using MIME encoding
  - Text files are embedded as CDATA sections with proper XML escaping
  - Binary files are base64-encoded
  - Handles CDATA end sequences (`]]>`) properly in text files
  - Special error handling for problematic files

- **Comprehensive Metadata**:
  - Full file path (`fqfn`) as absolute canonical path
  - MIME type (`type`) using the file utility
  - File size in bytes (`size`)
  - Modification timestamp (`modified`) in ISO 8601 format

- **Directory Support**:
  - Process entire directories recursively
  - Intelligently skip common irrelevant directories for performance
  - Combine files and directories in a single command
  - Smart directory pruning to avoid traversing ignored directories

- **Git Integration**:
  - Process all tracked files from Git repositories
  - Combine multiple repositories in a single command
  - Works alongside explicit file specifications
  - Preserves working directory when processing git repositories

- **Robust Processing**:
  - Configurable maximum file size limit (default: 1GB)
  - Custom file ignore patterns with glob support
  - Proper symlink resolution to canonical paths
  - Detailed error handling with continued processing
  - Full XML escaping for paths and filenames
  - Automatic file deduplication using canonical paths

- **Size Optimization**:
  - Content compression with gzip (`-c/--compress`)
  - Content omission for metadata-only output (`-n/--no-content`)
  - XML minification for compact output (`-M/--minify`)
  - All options can be combined for minimal output size

- **Flexibility**:
  - Outputs to stdout for pipeline integration
  - Can be sourced in other Bash scripts as a library
  - Configurable verbosity levels (normal, quiet, verbose)
  - Compatible with standard XML processing tools

## Installation

```bash
# Clone the repository
git clone https://github.com/Open-Technology-Foundation/files2xml.git
cd files2xml

# Make the script executable
chmod +x files2xml

# Run a simple test
./files2xml --version

# Optionally, install system-wide (requires sudo privileges)
sudo cp files2xml /usr/local/bin/

# Verify the installation
files2xml --help
```

### Verification

To verify all dependencies are installed:

```bash
# Check for dependency errors
./files2xml --help 2>&1 | grep "Required command not found"
```

If no output is produced, all dependencies are available.

## Usage

```bash
files2xml [OPTIONS] [FILE|DIRECTORY ...]
```

### Arguments
- `FILE|DIRECTORY` - One or more files or directories to include in the XML (optional if --gitdir is used)

### Options
- `-m, --max-file-size SIZE` - Set maximum file size (default: 1GB)
  - Uses human-readable format (e.g., "1G", "500M", "10K")
- `-g, --gitdir DIR` - Include files from git repository (can be used multiple times)
- `-i, --ignore PATTERN` - Add glob pattern to ignore list (can be used multiple times)
  - Default file patterns: `'*.mp*' '~*' '*~' '*.bak' '*.log' '*.old' '*LI*'`
  - Default dir patterns: `'__pycache__/*' '.cache/*' '.venv/*' 'venv/*' '.gudang/*' 'gudang/*'`
  - Use `-i ""` to clear the default patterns
- `-c, --compress` - Enable gzip compression for file content (reduces XML size)
- `-n, --no-content` - Exclude file content (metadata only, significantly reduces XML size)
- `-M, --minify` - Produce minified XML output (no indentation or extra whitespace)
- `-v, --verbose` - Increase verbosity (can be used multiple times)
- `-q, --quiet` - Suppress all messages
- `-V, --version` - Show version information
- `-h, --help` - Show help message

## Examples

### Basic Usage

Process specific files:
```bash
files2xml file1.txt file2.pdf > files.xml
```

### Directory Processing

Process a directory recursively:
```bash
files2xml /path/to/directory > directory_files.xml
```

Mix files and directories:
```bash
files2xml file1.txt /path/to/directory file2.pdf > mixed.xml
```

### Git Repository Integration

Process all tracked files in a Git repository:
```bash
files2xml --gitdir /path/to/repo > repo_files.xml
```

Combine multiple Git repositories:
```bash
files2xml --gitdir /path/to/repo1 --gitdir /path/to/repo2 > combined.xml
```

Mix Git repositories, directories, and specific files:
```bash
files2xml --gitdir /path/to/repo additional_file.txt /some/directory > combined.xml
```

### File Filtering

Specify custom ignore patterns (adds to default patterns):
```bash
files2xml --ignore "*.tmp" --ignore "*.cache" dir/*.py > files.xml
```

Clear default ignore patterns and set custom ones:
```bash
files2xml --ignore "" --ignore "*.tmp" --gitdir /path/to/repo > files.xml
```

### Size Optimization

Generate smaller XML with compression:
```bash
files2xml --compress /path/to/directory > compressed.xml
```

Generate metadata-only XML (no file content, much smaller):
```bash
files2xml --no-content /path/to/directory > metadata_only.xml
```

Generate minified XML (no whitespace or formatting):
```bash
files2xml --minify /path/to/directory > minified.xml
```

Combine all size-reduction options for smallest possible XML:
```bash
files2xml --compress --no-content --minify /path/to/directory > smallest.xml
```

### Integration with Other Tools

Process multiple files with find:
```bash
find . -type f -name "*.py" -exec files2xml {} + > output.xml
```

Extract specific file information with xmlstarlet:
```bash
# List all shell script filenames
files2xml *.sh | xmlstarlet sel -t -m "//file[contains(@type,'shellscript')]" -v "@fqfn" -n

# Get sizes of all text files
files2xml docs/* | xmlstarlet sel -t -m "//file[contains(@type,'text')]" -v "concat(@fqfn,': ',@size,' bytes')" -n

# Extract content from specific files
files2xml config.json | xmlstarlet sel -t -m "//file[@fqfn='/absolute/path/to/config.json']" -v "content" -n

# Find all files larger than 1MB
files2xml --gitdir . | xmlstarlet sel -t -m "//file[number(@size) > 1048576]" -v "concat(@fqfn,' (',@size,' bytes)')" -n
```

### File Size Limits

Set a custom maximum file size:
```bash
files2xml --max-file-size 10M large_directory/* > files.xml
```

## XML Format

The script generates XML with the following structure:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<Files>
  <!-- Text file example -->
  <file fqfn="/absolute/path/to/file.txt" type="text/plain" size="1234" modified="2025-04-15T10:30:45">
    <content><![CDATA[File content goes here...]]></content>
  </file>
  
  <!-- Binary file example -->
  <file fqfn="/absolute/path/to/image.png" type="image/png" size="5678" modified="2025-04-15T11:25:30">
    <content encoding="base64">base64encodedcontent...</content>
  </file>
  
  <!-- Compressed file example -->
  <file fqfn="/absolute/path/to/document.pdf" type="application/pdf" size="9012" modified="2025-04-15T12:20:15">
    <content encoding="base64" compression="gzip">compressedbase64content...</content>
  </file>
  
  <!-- Error example -->
  <file fqfn="/path/to/unreadable.dat" type="application/octet-stream" size="9999" modified="2025-04-15T12:15:00">
    <content error="failed_to_encode"/>
  </file>
  
  <!-- Metadata-only example -->
  <file fqfn="/path/to/config.json" type="application/json" size="2468" modified="2025-04-15T13:45:30">
    <content excluded="metadata_only"/>
  </file>
</Files>
```

### XML Attributes

| Attribute | Description |
|-----------|-------------|
| `fqfn` | Fully qualified file name (absolute path) |
| `type` | MIME type of the file (e.g., "text/plain", "application/pdf") |
| `size` | File size in bytes |
| `modified` | Last modification time (ISO 8601 format, e.g., "2025-04-15T10:30:45") |

### Content Element

| Attribute | Description |
|-----------|-------------|
| `encoding="base64"` | Present for binary files or compressed content |
| `compression="gzip"` | Present when compression is enabled with --compress |
| `error="failed_to_encode"` | Present when binary file encoding fails |
| `error="failed_to_process_cdata"` | Present when text file CDATA processing fails |
| `excluded="metadata_only"` | Present when --no-content option is used |

### Error Handling

When processing files, the script continues despite individual file errors, allowing batch processing to complete even if some files cannot be processed. Error attributes in the XML output provide information about what went wrong with specific files.

## Implementation Details

### Text vs Binary Detection

The script uses `file --mime-encoding` to determine if a file should be treated as text or binary:
- Text files are embedded directly as CDATA sections
- Binary files are encoded with base64

### Directory Processing

When processing directories, the script:
1. Recursively finds all files in the specified directories using `find`
2. Filters files against ignore patterns using multiple matching strategies
3. Intelligently prunes directories that match ignore patterns before traversing them (for performance)
4. Handles each file according to its type (text or binary)
5. Automatically deduplicates files that appear multiple times in the input

### Git Integration

When using `--gitdir`, the script:
1. Verifies the specified directory is a valid Git repository (contains .git directory)
2. Uses `git ls-files` to get all tracked files in the repository
3. Filters files against ignore patterns (same as directory processing)
4. Processes each file and includes it in the XML output
5. Preserves the current working directory (changes directory only temporarily)
6. Handles absolute paths correctly for all git-tracked files

### Error Handling

The script implements robust error handling:
- Continues processing when individual files fail (non-fatal errors)
- Provides detailed error messages through stderr
- Uses proper exit codes for different failure scenarios
- Includes error attributes in XML for problematic files
- Traps errors to provide context-specific failure information
- Skips files exceeding the maximum size limit with appropriate messages

### Symlink Resolution

Symbolic links are resolved to their actual target files using `readlink -m` to ensure:
1. The actual file content is processed, not the symlink itself
2. Absolute canonical paths are used for all file references
3. File deduplication works correctly even with multiple links to the same file
4. Path attributes in the XML always refer to canonical file locations

## Integration in Scripts

The `files2xml` script can be sourced in other Bash scripts to use its functions directly:

```bash
source /path/to/files2xml

# Use the files_to_xml function directly
files_to_xml file1.txt file2.txt | process_xml
```

## Requirements

- **Bash**: Version 5.2.21 or higher (for associative arrays and other features)
- **Git**: For repository integration functionality (optional, only required when using --gitdir)
- **Standard Unix utilities**:
  - `basename`: For extracting filenames
  - `file`: For MIME type and encoding detection
  - `stat`: For file metadata
  - `date`: For formatting timestamps
  - `sed`: For processing text content and CDATA handling
  - `base64`: For encoding binary files
  - `readlink`: For resolving symlinks and canonical paths
  - `numfmt`: For human-readable file size conversion
  - `getopt`: For command-line argument parsing
  - `gzip`: For content compression (only required when using --compress)
  - `find`: For directory traversal
  
The script automatically checks for required dependencies and will display an error message if any are missing.

## Troubleshooting

### Common Issues

- **"No input files specified"**: Ensure you've provided file paths, directories, or used `--gitdir`.
- **"File too large"**: Use `--max-file-size` with a larger value if needed (e.g., `--max-file-size 2G`).
- **"Required command not found"**: Ensure all listed utilities are installed and in your PATH.
- **"No .git directory"**: Verify the path provided to `--gitdir` is a valid Git repository.
- **"Failed to resolve path"**: Check the file exists and has correct permissions.
- **"Invalid --max-file-size format"**: Use proper format with suffix (K, M, G, etc.).

### File Processing Errors

If specific files fail to process:
1. Check file permissions (must be readable by the user running the script)
2. Verify the file isn't corrupted (try opening it with other applications)
3. Confirm the file size is within limits (check with `ls -lh filename`)
4. Check if the file is being ignored by a pattern (run with `-v` for verbose output)
5. Ensure special files (devices, sockets, etc.) are not included (only regular files are supported)

### Debugging

If you encounter issues:
1. Run with increased verbosity (`-v` or `-vv`) to see detailed processing information
2. Check stderr for detailed error messages (`./files2xml ... 2>errors.log`)
3. Verify XML output validity with xmllint (`./files2xml ... | xmllint --format -`)
4. For Git integration issues, verify Git is installed and working (`git --version`)

## License

[GPL-3 License](LICENSE)