#!/bin/bash
# Test content compression option

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test files
LARGE_TEXT_FILE="$RESULTS_DIR/large_text.txt"
OUTPUT_NORMAL="$RESULTS_DIR/compress_normal.xml"
OUTPUT_COMPRESSED="$RESULTS_DIR/compress_compressed.xml"

echo "Testing content compression option..."

# Create a larger text file with repetitive content for better compression
{
    for i in {1..50}; do
        echo "This is line $i with repetitive content that should compress well. The quick brown fox jumps over the lazy dog."
    done
} > "$LARGE_TEXT_FILE"

# Run files2xml normally
"$SCRIPT" "$LARGE_TEXT_FILE" > "$OUTPUT_NORMAL"
assert_equals 0 $? "Normal execution should exit with status 0"

# Run files2xml with compression option
"$SCRIPT" -c "$LARGE_TEXT_FILE" > "$OUTPUT_COMPRESSED"
assert_equals 0 $? "Compressed execution should exit with status 0"

# Validate both outputs
validate_xml "$OUTPUT_NORMAL" || exit 1
validate_xml "$OUTPUT_COMPRESSED" || exit 1

# Check for file presence
check_file_in_xml "$OUTPUT_NORMAL" "large_text.txt" || {
    echo "Failed: large_text.txt missing from normal output"
    exit 1
}

check_file_in_xml "$OUTPUT_COMPRESSED" "large_text.txt" || {
    echo "Failed: large_text.txt missing from compressed output"
    exit 1
}

# Check for compression attributes
if ! grep -q "compression=\"gzip\"" "$OUTPUT_COMPRESSED"; then
    echo "Failed: compression attribute missing from compressed output"
    exit 1
fi

if grep -q "compression=\"gzip\"" "$OUTPUT_NORMAL"; then
    echo "Failed: compression attribute found in normal output"
    exit 1
fi

# Check that compressed output uses base64 encoding
if ! grep -q "encoding=\"base64\"" "$OUTPUT_COMPRESSED"; then
    echo "Failed: base64 encoding attribute missing from compressed output"
    exit 1
fi

# Original content should be CDATA, not base64
if ! grep -q "<!\[CDATA\[" "$OUTPUT_NORMAL"; then
    echo "Failed: CDATA not found in normal output"
    exit 1
fi

# Compressed output should be smaller (not guaranteed but highly likely for repetitive text)
normal_size=$(get_file_size "$OUTPUT_NORMAL")
compressed_size=$(get_file_size "$OUTPUT_COMPRESSED")

echo "Normal size: $normal_size bytes"
echo "Compressed size: $compressed_size bytes"

# For large repetitive text, compression should help
# But for small files, compression overhead might make it larger
# So we'll only test if the file is large enough
if [[ $normal_size -gt 1000 ]]; then
    if [[ $compressed_size -ge $normal_size ]]; then
        echo "Warning: Compressed output ($compressed_size bytes) is not smaller than normal output ($normal_size bytes)"
        # This is a warning, not a failure, as compression effectiveness depends on content
    fi
fi

echo "Compression option test completed successfully"
exit 0