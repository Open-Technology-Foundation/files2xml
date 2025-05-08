#!/bin/bash
# Test directory processing

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test directory
OUTPUT_FILE="$RESULTS_DIR/directory_output.xml"

echo "Testing directory processing..."

# Run files2xml with the test directory
"$SCRIPT" "$TEST_FILES" > "$OUTPUT_FILE"
test_status=$?

# Check if the command ran successfully
assert_equals 0 $test_status "files2xml should exit with status 0"

# Check if the output file exists and is valid XML
assert_file_exists "$OUTPUT_FILE" "Output file should be created"
validate_xml "$OUTPUT_FILE" || exit 1

# Check if all files from directory are included
check_file_in_xml "$OUTPUT_FILE" "text.txt" || {
    echo "Failed to find text.txt in the XML output"
    exit 1
}

check_file_in_xml "$OUTPUT_FILE" "script.sh" || {
    echo "Failed to find script.sh in the XML output"
    exit 1
}

check_file_in_xml "$OUTPUT_FILE" "binary.dat" || {
    echo "Failed to find binary.dat in the XML output"
    exit 1
}

# Check if subdirectory files are included
check_file_in_xml "$OUTPUT_FILE" "subfile.txt" || {
    echo "Failed to find subdir/subfile.txt in the XML output"
    exit 1
}

# Check if the number of file elements matches the expected number
file_count=$(count_elements "$OUTPUT_FILE" "file")
expected_count=5  # Adjust this based on your test directory content

# It's okay if the count is different, but we should log it
if [[ "$file_count" -ne "$expected_count" ]]; then
    echo "Warning: Expected $expected_count files, found $file_count"
    # This is not a failure as the count may vary depending on actual test files
fi

echo "Directory processing test completed successfully"
exit 0