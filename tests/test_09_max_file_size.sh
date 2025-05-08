#!/bin/bash
# Test maximum file size option

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test files
LARGE_FILE="$RESULTS_DIR/oversized.dat"
SMALL_FILE="$RESULTS_DIR/undersized.dat"
OUTPUT_DEFAULT="$RESULTS_DIR/size_default.xml"
OUTPUT_CUSTOM="$RESULTS_DIR/size_custom.xml"

echo "Testing maximum file size option..."

# Create files of different sizes
dd if=/dev/urandom of="$LARGE_FILE" bs=1M count=2 &>/dev/null  # 2MB file
dd if=/dev/urandom of="$SMALL_FILE" bs=100K count=1 &>/dev/null  # 100KB file

# Run files2xml with default max size (should include both files)
"$SCRIPT" "$LARGE_FILE" "$SMALL_FILE" > "$OUTPUT_DEFAULT"
assert_equals 0 $? "Default max size should exit with status 0"

# Run files2xml with custom max size of 500KB (should exclude the large file)
"$SCRIPT" --max-file-size 500K "$LARGE_FILE" "$SMALL_FILE" > "$OUTPUT_CUSTOM"
assert_equals 0 $? "Custom max size should exit with status 0"

# Validate outputs
validate_xml "$OUTPUT_DEFAULT" || exit 1
validate_xml "$OUTPUT_CUSTOM" || exit 1

# Default should include both files
large_basename=$(basename "$LARGE_FILE")
small_basename=$(basename "$SMALL_FILE")

check_file_in_xml "$OUTPUT_DEFAULT" "$large_basename" || {
    echo "Failed: $large_basename missing from default output"
    exit 1
}

check_file_in_xml "$OUTPUT_DEFAULT" "$small_basename" || {
    echo "Failed: $small_basename missing from default output"
    exit 1
}

# Custom should only include the small file
if grep -q "$large_basename" "$OUTPUT_CUSTOM"; then
    echo "Failed: $large_basename should be excluded by max file size"
    exit 1
fi

check_file_in_xml "$OUTPUT_CUSTOM" "$small_basename" || {
    echo "Failed: $small_basename missing from custom output"
    exit 1
}

# Test with invalid size format
if "$SCRIPT" --max-file-size INVALID "$SMALL_FILE" > /dev/null 2>&1; then
    echo "Failed: Invalid max-file-size should cause an error"
    exit 1
fi

echo "Maximum file size option test completed successfully"
exit 0