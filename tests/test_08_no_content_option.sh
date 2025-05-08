#!/bin/bash
# Test no-content option

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test file
TEST_TEXT_FILE="$TEST_FILES/text.txt"
OUTPUT_NORMAL="$RESULTS_DIR/content_normal.xml"
OUTPUT_NO_CONTENT="$RESULTS_DIR/content_no_content.xml"

echo "Testing no-content option..."

# Run files2xml normally
"$SCRIPT" "$TEST_TEXT_FILE" > "$OUTPUT_NORMAL"
assert_equals 0 $? "Normal execution should exit with status 0"

# Run files2xml with no-content option
"$SCRIPT" -n "$TEST_TEXT_FILE" > "$OUTPUT_NO_CONTENT"
assert_equals 0 $? "No-content execution should exit with status 0"

# Validate both outputs
validate_xml "$OUTPUT_NORMAL" || exit 1
validate_xml "$OUTPUT_NO_CONTENT" || exit 1

# Check for file presence
check_file_in_xml "$OUTPUT_NORMAL" "text.txt" || {
    echo "Failed: text.txt missing from normal output"
    exit 1
}

check_file_in_xml "$OUTPUT_NO_CONTENT" "text.txt" || {
    echo "Failed: text.txt missing from no-content output"
    exit 1
}

# Check for content in normal output
if ! grep -q "This is a plain text file" "$OUTPUT_NORMAL"; then
    echo "Failed: Content missing from normal output"
    exit 1
fi

# Check for excluded attribute in no-content output
if ! grep -q "excluded=\"metadata_only\"" "$OUTPUT_NO_CONTENT"; then
    echo "Failed: excluded attribute missing from no-content output"
    exit 1
fi

# Check that content is actually excluded
if grep -q "This is a plain text file" "$OUTPUT_NO_CONTENT"; then
    echo "Failed: Content found in no-content output"
    exit 1
fi

# No-content output should be smaller
normal_size=$(get_file_size "$OUTPUT_NORMAL")
no_content_size=$(get_file_size "$OUTPUT_NO_CONTENT")

if [[ $no_content_size -ge $normal_size ]]; then
    echo "Failed: No-content output ($no_content_size bytes) is not smaller than normal output ($normal_size bytes)"
    exit 1
fi

echo "No-content option test completed successfully"
exit 0