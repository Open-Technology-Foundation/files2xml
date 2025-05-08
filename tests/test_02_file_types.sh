#!/bin/bash
# Test handling of different file types

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test file paths
TEXT_FILE="$TEST_FILES/text.txt"
SCRIPT_FILE="$TEST_FILES/script.sh"
BINARY_FILE="$TEST_FILES/binary.dat"
CDATA_TEST_FILE="$TEST_FILES/cdata_test.txt"
OUTPUT_FILE="$RESULTS_DIR/file_types_output.xml"

echo "Testing handling of different file types..."

# Run files2xml with all test files
"$SCRIPT" "$TEXT_FILE" "$SCRIPT_FILE" "$BINARY_FILE" "$CDATA_TEST_FILE" > "$OUTPUT_FILE"
test_status=$?

# Check if the command ran successfully
assert_equals 0 $test_status "files2xml should exit with status 0"

# Check if the output file exists and is valid XML
assert_file_exists "$OUTPUT_FILE" "Output file should be created"
validate_xml "$OUTPUT_FILE" || exit 1

# Check text file
check_file_in_xml "$OUTPUT_FILE" "text.txt" || {
    echo "Failed to find text.txt in the XML output"
    exit 1
}

# Check script file
check_file_in_xml "$OUTPUT_FILE" "script.sh" || {
    echo "Failed to find script.sh in the XML output"
    exit 1
}

# Check binary file
check_file_in_xml "$OUTPUT_FILE" "binary.dat" || {
    echo "Failed to find binary.dat in the XML output"
    exit 1
}

# Check CDATA escaping in the file with the CDATA end sequence
check_file_in_xml "$OUTPUT_FILE" "cdata_test.txt" || {
    echo "Failed to find cdata_test.txt in the XML output"
    exit 1
}

# Check if binary file is base64 encoded
grep -q "encoding=\"base64\"" "$OUTPUT_FILE" || {
    echo "Failed to find base64 encoding for binary file"
    exit 1
}

# Check if CDATA escaping works correctly
if grep -q "]]>" "$OUTPUT_FILE"; then
    # If we find an unescaped CDATA end sequence, the test fails
    if ! grep -q "]]]]><!\[CDATA\[>" "$OUTPUT_FILE"; then
        echo "CDATA escaping doesn't work correctly"
        exit 1
    fi
fi

echo "File types test completed successfully"
exit 0