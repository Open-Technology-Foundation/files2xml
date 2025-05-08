# Development Guide for files2xml

This document provides detailed information for developers who want to understand, modify, or contribute to the `files2xml` project.

## Development Environment Setup

### Requirements

- **Operating System**: Ubuntu 24.04.2 or compatible Linux distribution
- **Bash**: Version 5.2.21 or higher (required for associative arrays and other features)
- **Git**: For version control and repository features
- **XML Tools**: xmlstarlet and xmllint are recommended for testing output
- **Text Editor**: Any preferred code editor with Bash syntax highlighting

### Essential Utilities

The following standard Unix utilities are required:
- basename
- file
- stat
- date
- sed
- base64
- readlink
- numfmt
- getopt

### Development Setup Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Open-Technology-Foundation/files2xml.git
   cd files2xml
   ```

2. **Make Script Executable**:
   ```bash
   chmod +x files2xml
   ```

3. **Set Up Testing Environment**:
   ```bash
   # Create test files of various types
   mkdir -p test/{text,binary,mixed}
   echo "Test content" > test/text/sample.txt
   cp /bin/ls test/binary/sample.bin  # Example binary file
   
   # Install XML testing tools (if needed)
   sudo apt install xmlstarlet libxml2-utils
   ```

## Code Structure

### Main Components

The `files2xml` script is organized into several functional components:

1. **Constants and Configuration**: 
   - Defined at the top of the script
   - Includes XML version, encoding, default max file size, and ignore patterns

2. **Utility Functions**:
   - `xml_escape()`: Escape XML special characters
   - `stderr()`: Error reporting
   - `check_commands()`: Verify required tools are available

3. **Core Processing**:
   - `files_to_xml()`: Main function to process files and generate XML

4. **Git Integration**:
   - `check_git_available()`: Verify Git is installed
   - `get_git_dirs()`: Process Git repositories

5. **Command Line Interface**:
   - `usage()`: Display help information
   - `main()`: Parse options and orchestrate processing

### Control Flow

The script follows this general control flow:

1. Parse command-line arguments
2. Collect file paths from arguments and/or Git repositories
3. Process each file:
   - Resolve symlinks and get absolute paths
   - Determine if file is text or binary
   - Extract metadata
   - Process and encode content appropriately
4. Output XML document to stdout

## Coding Standards

### Shell Scripting Style

Follow these style guidelines when contributing:

- **Indentation**: 2 spaces (no tabs)
- **Line Length**: Aim for 80 characters where reasonable
- **Shebang Line**: Always use `#!/bin/bash` 
- **Error Handling**: Always include `set -euo pipefail` at the start

### Variable Declarations

- Always declare variables before use with appropriate scope and type:
  ```bash
  # Constants (read-only)
  declare -r CONSTANT_NAME='value'
  
  # Integers
  declare -i SOME_NUMBER=42
  
  # Arrays
  declare -a REGULAR_ARRAY=('item1' 'item2')
  
  # Associative arrays
  declare -A HASH_TABLE=([key1]=value1 [key2]=value2)
  
  # Local variables in functions
  local var_name="value"
  ```

### Conditionals

- Prefer `[[` over `[` for conditionals:
  ```bash
  if [[ "$variable" == "value" ]]; then
    # ...
  fi
  ```

- For simple conditions, consider using `&&`:
  ```bash
  [[ -f "$file" ]] && process_file "$file"
  ```

### Function Documentation

All functions should be documented following this format:

```bash
# Brief description of function purpose
# 
# Args:
#   $1 - Description of first argument
#   $2 - Description of second argument
# Returns:
#   0 - Success description
#   1 - Error condition description
# Outputs:
#   Description of stdout/stderr output
# Examples:
#   function_name arg1 arg2
function_name() {
  # Implementation
}
```

### Error Handling

- Use the `stderr()` function for reporting errors
- Return appropriate exit codes (0 for success, non-zero for errors)
- Include informative error messages that guide the user to a solution
- Continue processing where possible despite individual file errors

## Testing

### Manual Testing

To test the script manually:

1. **Basic Functionality**:
   ```bash
   ./files2xml path/to/text/file.txt > output.xml
   xmllint --format output.xml
   ```

2. **Git Integration**:
   ```bash
   ./files2xml --gitdir . > repo.xml
   ```

3. **File Type Detection**:
   ```bash
   # Test with text and binary files
   ./files2xml /bin/bash text.txt > mixed.xml
   ```

4. **XML Processing**:
   ```bash
   # Extract all filenames
   ./files2xml *.sh | xmlstarlet sel -t -m "//file" -v "@fqfn" -n
   
   # Get sizes of all text files
   ./files2xml * | xmlstarlet sel -t -m "//file[contains(@type,'text')]" -v "concat(@fqfn,': ',@size,' bytes')" -n
   ```

### Test Cases

When implementing new features or fixes, test at minimum:

1. Text files with various encodings
2. Binary files of different types
3. Files with special characters in names
4. Large files (near size limit)
5. Files with CDATA end markers (`]]>`) in content
6. Git repositories with mixed content types
7. Error conditions (unreadable files, missing dependencies)

## Contribution Workflow

### Making Changes

1. **Create a Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Implement Changes**: Follow the coding standards above

3. **Test Your Changes**: Ensure all functionality works as expected

4. **Update Documentation**: If your changes affect user-facing features, update README.md and inline comments

### Submitting Changes

1. **Push Your Branch**:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a Pull Request**: 
   - Provide a clear description of the changes
   - Reference any related issues
   - Explain testing performed

3. **Code Review**:
   - Address any feedback from maintainers
   - Make requested changes

## Architecture & Design Principles

### XML Structure Design

The XML output follows a simple, attribute-based structure to facilitate processing with standard XML tools:

```xml
<Files>
  <file fqfn="/absolute/path/to/file.txt" type="text/plain" size="1234" modified="2025-04-15T10:30:45">
    <content><![CDATA[File content goes here...]]></content>
  </file>
  <file fqfn="/absolute/path/to/image.png" type="image/png" size="5678" modified="2025-04-15T11:25:30">
    <content encoding="base64">base64encodedcontent...</content>
  </file>
  <!-- More files -->
</Files>
```

This design allows easy extraction of specific data using XPath expressions or XSLT transformations. All file metadata is stored as attributes on the `file` element, making it simpler to query and process with standard XML tools.

### Extension Points

When extending functionality, consider these primary extension points:

1. **File Type Detection**: Enhance MIME type detection for specialized file formats
2. **Content Processing**: Add special handling for specific file types
3. **Metadata Extraction**: Add additional metadata fields where valuable
4. **Integration Options**: Expand compatibility with other systems/tools

### Performance Considerations

- **Large Files**: Process files in chunks for very large text files if needed
- **Memory Usage**: Be mindful of in-memory processing, especially for base64 encoding
- **Deduplication**: The script already includes file deduplication; maintain this efficiency

## Troubleshooting Development Issues

### Common Development Problems

1. **Bash Version Compatibility**:
   - Issue: Script uses features not available in older Bash versions
   - Solution: Check Bash version with `bash --version` and ensure it's 5.2.21+

2. **Permissions Issues**:
   - Issue: Script can't access certain files
   - Solution: Check/modify file permissions with `chmod`

3. **XML Processing Errors**:
   - Issue: Invalid XML output
   - Solution: Use `xmllint --format` to identify formatting issues

4. **Git Integration**:
   - Issue: Git functionality not working
   - Solution: Ensure Git is installed and the path is a valid repository

### Debugging

1. **Increase Verbosity**: Use the `-v` or `-vv` flags for progressively more detailed processing information:
   ```bash
   # Basic verbose output (shows which files are processed)
   ./files2xml -v file.txt
   
   # Very verbose output (shows pattern matching, detailed operations)
   ./files2xml -vv file.txt
   ```

2. **Redirect Error Output**: Capture error messages and debug information in a log file:
   ```bash
   ./files2xml file.txt > output.xml 2> debug.log
   ```

3. **Add Temporary Debug Output**: Insert additional debug statements to examine variables or logic:
   ```bash
   # In any section of code, add debug statements conditioned on verbosity
   ((VERBOSE)) && { stderr "DEBUG: variable=$variable"; }
   ((VERBOSE > 1)) && { stderr "TRACE: Entered function at $(date +%T.%N)"; }
   ```

4. **Test Individual Functions**: Source the script to test functions in isolation:
   ```bash
   source ./files2xml
   xml_escape "<test & string>"
   check_commands
   ```

5. **Examine XML Output**: Use XML tools to verify the structure of produced XML:
   ```bash
   ./files2xml file.txt | xmllint --format -
   ```

6. **Test Pattern Matching**: Debug pattern matching issues with explicit tests:
   ```bash
   [[ "path/to/file.txt" == *.txt ]] && echo "Pattern matched" || echo "Pattern did not match"
   ```

## Release Process

### Versioning

The project follows semantic versioning (MAJOR.MINOR.PATCH):
- MAJOR: Incompatible API changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes (backward compatible)

### Release Steps

1. **Update Version**: Change the VERSION variable in the script
2. **Update Documentation**: Ensure README.md reflects new features/changes
3. **Create Release Tag**:
   ```bash
   git tag -a v1.2.3 -m "Version 1.2.3"
   git push origin v1.2.3
   ```

## Project Structure

```
files2xml/
├── files2xml        # Main script
├── README.md        # User documentation
├── DEVELOPMENT.md   # Developer documentation
├── LICENSE          # GPL-3 license
└── test/            # Test files and tests (if added)
```