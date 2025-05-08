#!/bin/bash
#
# install.sh - System-wide installation script for files2xml
#
# This script handles:
# - Downloading the latest version from GitHub
# - Checking and installing dependencies
# - System-wide installation of the script and man page
# - Verifying the installation
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Open-Technology-Foundation/files2xml/main/install.sh | sudo bash
#   or
#   wget -qO- https://raw.githubusercontent.com/Open-Technology-Foundation/files2xml/main/install.sh | sudo bash
#

set -euo pipefail

# Configuration
REPO_URL="https://github.com/Open-Technology-Foundation/files2xml"
TEMP_DIR=$(mktemp -d)
INSTALL_PATH="/usr/local/bin/files2xml"
MAN_PATH="/usr/local/share/man/man1/files2xml.1"
DOC_PATH="/usr/local/share/doc/files2xml"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
(( $(id -u) )) && {
  >&2 echo -e "${RED}Error: This installation script must be run as root (sudo).${NC}"
  >&2 echo "Please run with: sudo $0"
  exit 1
}

# Print banner
echo -e "${BLUE}"
echo "╔════════════════════════════════════════════╗"
echo "║         files2xml Installation Script       ║"
echo "╚════════════════════════════════════════════╝"
echo -e "${NC}"

# Function to check if a command exists
cmd_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Check for required commands
echo -e "${BLUE}Checking for required commands...${NC}"
REQUIRED_CMDS=("wget" "git" "basename" "file" "stat" "date" "sed" "base64" "readlink" "numfmt" "getopt")

MISSING_CMDS=()
for cmd in "${REQUIRED_CMDS[@]}"; do
  if ! cmd_exists "$cmd"; then
    MISSING_CMDS+=("$cmd")
  fi
done

# If there are missing commands, try to install them
if (( ${#MISSING_CMDS[@]} )); then
  echo -e "${YELLOW}Some required commands are missing: ${MISSING_CMDS[*]}${NC}"
  echo -e "${BLUE}Attempting to install missing dependencies...${NC}"
  
  # Detect package manager
  if cmd_exists apt-get; then
    echo "Using apt package manager"
    apt-get update
    apt-get install -y "${MISSING_CMDS[@]}" git pandoc
  elif cmd_exists dnf; then
    echo "Using dnf package manager"
    dnf install -y "${MISSING_CMDS[@]}" git pandoc
  elif cmd_exists yum; then
    echo "Using yum package manager"
    yum install -y "${MISSING_CMDS[@]}" git pandoc
  elif cmd_exists pacman; then
    echo "Using pacman package manager"
    pacman -Sy --noconfirm "${MISSING_CMDS[@]}" git pandoc
  else
    >&2 echo -e "${RED}Could not determine package manager. Please install these dependencies manually: ${MISSING_CMDS[*]}${NC}"
    exit 1
  fi
fi

# Check for optional dependencies
echo -e "${BLUE}Checking for optional dependencies...${NC}"
OPTIONAL_CMDS=("gzip" "xmllint" "xmlstarlet" "pandoc")
MISSING_OPT_CMDS=()

for cmd in "${OPTIONAL_CMDS[@]}"; do
  if ! cmd_exists "$cmd"; then
    MISSING_OPT_CMDS+=("$cmd")
  fi
done

if (( ${#MISSING_OPT_CMDS[@]} )); then
  echo -e "${YELLOW}Some optional dependencies are missing: ${MISSING_OPT_CMDS[*]}"
  echo -e "These are not required, but recommended for full functionality.${NC}"
  
  read -r -n 1 -p 'Do you want to install optional dependencies?  y/n '
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Detect package manager
    if cmd_exists apt-get; then
      echo "Using apt package manager"
      apt-get update
      apt-get install -y gzip libxml2-utils xmlstarlet pandoc
    elif cmd_exists dnf; then
      echo "Using dnf package manager"
      dnf install -y gzip libxml2 xmlstarlet pandoc
    elif cmd_exists yum; then
      echo "Using yum package manager"
      yum install -y gzip libxml2 xmlstarlet pandoc
    elif cmd_exists pacman; then
      echo "Using pacman package manager"
      pacman -Sy --noconfirm gzip libxml2 xmlstarlet pandoc
    else
      echo -e "${YELLOW}Could not determine package manager. Please install these dependencies manually if needed.${NC}"
    fi
  fi
fi

# Download files2xml from repository
echo -e "${BLUE}Downloading files2xml from repository...${NC}"
cd "$TEMP_DIR"
git clone --depth 1 "$REPO_URL" files2xml-repo
cd files2xml-repo

# Verify Bash version
BASH_VERSION=$(bash --version | head -n1 | cut -d' ' -f4 | cut -d'.' -f1,2)
REQUIRED_VERSION="5.2"

if (( $(echo "$BASH_VERSION < $REQUIRED_VERSION" | bc -l) )); then
  echo -e "${YELLOW}Warning: Your Bash version ($BASH_VERSION) is older than the recommended version ($REQUIRED_VERSION).${NC}"
  echo "files2xml may not function correctly. Consider upgrading Bash."
  read -p "Do you want to continue anyway? [y/N] " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    >&2 echo "Installation cancelled."
    rm -rf "$TEMP_DIR"
    exit 1
  fi
fi

# Make the script executable
chmod +x files2xml

# Verify the script works
echo -e "${BLUE}Verifying script functionality...${NC}"
./files2xml --version

# Generate man page
echo -e "${BLUE}Generating man page...${NC}"
if cmd_exists pandoc; then
  # If create_manpage.sh exists, use it
  if [ -f "create_manpage.sh" ]; then
    chmod +x create_manpage.sh
    ./create_manpage.sh
  else
    # Otherwise create a simple pandoc command
    VERSION=$(grep -m 1 'VERSION=' "files2xml" | cut -d'"' -f2 || echo "1.0.0")
    
    # Create a header with proper man page metadata
    TMP_MD=$(mktemp)
    cat > "$TMP_MD" << EOF
---
title: files2xml
section: 1
header: User Manual
footer: files2xml $VERSION
date: $(date +"%B %d, %Y")
---

EOF
    
    # Append the README content, but skip the very first line (# files2xml)
    tail -n +2 "README.md" >> "$TMP_MD"
    
    # Convert to man page
    pandoc "$TMP_MD" -f markdown -t man -s -o "files2xml.1"
    rm "$TMP_MD"
  fi
else
  >&2 echo -e "${YELLOW}pandoc not found. Skipping man page generation.${NC}"
fi

# Install files2xml
echo -e "${BLUE}Installing files2xml system-wide...${NC}"
install -v -m 755 files2xml "$INSTALL_PATH"

# Install man page if it exists
if [ -f "files2xml.1" ]; then
  echo -e "${BLUE}Installing man page...${NC}"
  mkdir -p "$(dirname "$MAN_PATH")"
  install -v -m 644 files2xml.1 "$MAN_PATH"
  mandb &>/dev/null || true
fi

# Install documentation
echo -e "${BLUE}Installing documentation...${NC}"
mkdir -p "$DOC_PATH"
cp -v README.md CONTRIBUTING.md LICENSE "$DOC_PATH/" 2>/dev/null || true
[ -f DEVELOPMENT.md ] && cp -v DEVELOPMENT.md "$DOC_PATH/"

# Cleanup
rm -rf "$TEMP_DIR"

# Verify installation
if cmd_exists files2xml; then
  VERSION=$(files2xml --version)
  echo -e "${GREEN}✓ files2xml installed successfully: $VERSION${NC}"
  echo -e "You can now use files2xml from anywhere in your system."
  echo -e "View the man page with: ${BLUE}man files2xml${NC}"
  echo -e "Documentation is available at: ${BLUE}$DOC_PATH${NC}"
else
  >&2 echo -e "${RED}Error: Installation failed!${NC}"
  exit 1
fi

echo -e "${GREEN}Installation complete!${NC}"

#fin
