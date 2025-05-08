# Contributing to files2xml

Thank you for your interest in contributing to files2xml! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Submitting Changes](#submitting-changes)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Documentation](#documentation)

## Code of Conduct

Please be respectful and considerate of others when contributing to this project. We strive to maintain a welcoming and inclusive environment for all contributors.

## Getting Started

1. **Fork the repository** on GitHub: https://github.com/Open-Technology-Foundation/files2xml
2. **Clone your fork** to your local machine:
   ```bash
   git clone https://github.com/YOUR-USERNAME/files2xml.git
   cd files2xml
   ```
3. **Set up upstream remote**:
   ```bash
   git remote add upstream https://github.com/Open-Technology-Foundation/files2xml.git
   ```
4. **Create a new branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Workflow

1. **Ensure you have the prerequisites** installed:
   - Bash 5.2.21 or higher
   - Git
   - xmlstarlet and xmllint for testing
   - Standard Unix utilities (basename, file, stat, date, sed, base64, readlink, numfmt, getopt)

2. **Make the script executable**:
   ```bash
   chmod +x files2xml
   ```

3. **Set up the testing environment** as described in [DEVELOPMENT.md](DEVELOPMENT.md)

4. **Make your changes**, following the [coding standards](#coding-standards)

5. **Test your changes** thoroughly (see [Testing](#testing))

6. **Update documentation** if necessary

7. **Commit your changes** with a descriptive commit message:
   ```bash
   git add .
   git commit -m "Add feature: description of your changes"
   ```

## Submitting Changes

1. **Push your changes** to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create a pull request** from your branch to the main repository's main branch.

3. In your pull request, include:
   - A clear title and description of the changes
   - Any relevant issue numbers using the format `Fixes #123`
   - A summary of the testing you performed
   - Any notes on documentation updates

4. **Respond to code review feedback** and make any requested changes.

5. Once approved, your pull request will be merged by a project maintainer.

## Coding Standards

Please follow these standards when contributing code:

### Shell Scripting Style

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

## Testing

Before submitting a pull request, make sure all tests pass:

```bash
cd tests
./run_tests.sh
```

For new features, add new test cases to cover your changes. All code should have appropriate test coverage.

When implementing new features or fixes, test at minimum:

1. Text files with various encodings
2. Binary files of different types
3. Files with special characters in names
4. Large files (near size limit)
5. Files with CDATA end markers (`]]>`) in content
6. Git repositories with mixed content types
7. Error conditions (unreadable files, missing dependencies)

## Documentation

- If you add or modify features, update the README.md file accordingly
- Ensure all function documentation is up to date
- If you change behavior, update both the main script documentation and external documentation (DEVELOPMENT.md and README.md)
- For significant changes, consider updating examples in the documentation

Thank you for contributing to files2xml!