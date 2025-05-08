#!/bin/bash
# Test basic functionality of files2xml

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test file paths
TEST_TEXT_FILE="$TEST_FILES/text.txt"
OUTPUT_FILE="$RESULTS_DIR/basic_output.xml"

echo "Testing basic functionality..."

# Run files2xml with a simple text file
"$SCRIPT" "$TEST_TEXT_FILE" > "$OUTPUT_FILE"
test_status=$?

# Check if the command ran successfully
assert_equals 0 $test_status "files2xml should exit with status 0"

# Check if the output file exists and is valid XML
assert_file_exists "$OUTPUT_FILE" "Output file should be created"

# Validate XML structure
validate_xml "$OUTPUT_FILE" || exit 1

# Check if the file appears in the XML
check_file_in_xml "$OUTPUT_FILE" "text.txt" || {
    echo "Failed to find text.txt in the XML output"
    exit 1
}

# Check if the content is included
grep -q "This is a plain text file" "$OUTPUT_FILE" || {
    echo "Failed to find file content in the XML output"
    exit 1
}

# Check for attribute-based structure
grep -q "<file fqfn=" "$OUTPUT_FILE" || {
    echo "Failed to find attribute-based file structure"
    exit 1
}

echo "Basic functionality test completed successfully"
exit 0