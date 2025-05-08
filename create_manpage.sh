#!/bin/bash
#
# create_manpage.sh - Generate a man page from README.md for files2xml
#
# This script converts the README.md to a man page format and installs
# it to the appropriate location in the man pages hierarchy.
#
set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
README_PATH="$SCRIPT_DIR/README.md"
MAN_OUTPUT="$SCRIPT_DIR/files2xml.1"
TEMP_FILE=$(mktemp)

# Check if pandoc is installed
if ! command -v pandoc &>/dev/null; then
    echo "Error: pandoc is required but not installed."
    echo "Install it with: sudo apt install pandoc"
    exit 1
fi

# Extract version from the script
VERSION=$(grep -m 1 'VERSION=' "$SCRIPT_DIR/files2xml" | cut -d'"' -f2 || echo "1.0.0")

# Create a header with proper man page metadata
cat > "$TEMP_FILE" << EOF
---
title: files2xml
section: 1
header: User Manual
footer: files2xml $VERSION
date: $(date +"%B %d, %Y")
---

EOF

# Append the README content, but skip the very first line (# files2xml)
# as we'll have a proper .TH title from the YAML header
tail -n +2 "$README_PATH" >> "$TEMP_FILE"

echo "Generating man page..."
pandoc "$TEMP_FILE" \
    -f markdown \
    -t man \
    -s \
    -o "$MAN_OUTPUT"

# Clean up
rm "$TEMP_FILE"

echo "Man page generated at: $MAN_OUTPUT"
echo
echo "To view the man page:"
echo "  man -l $MAN_OUTPUT"
echo
echo "To install the man page system-wide (requires sudo):"
echo "  sudo mkdir -p /usr/local/share/man/man1"
echo "  sudo cp $MAN_OUTPUT /usr/local/share/man/man1/"
echo "  sudo mandb"
echo
echo "After installation, you can view it with:"
echo "  man files2xml"

# Make the script executable
chmod +x "$MAN_OUTPUT"