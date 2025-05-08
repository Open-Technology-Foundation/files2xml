#!/bin/bash
# Test Git repository integration

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test Git repository
GIT_REPO="$TEST_DIR/git_repo"
OUTPUT_FILE="$RESULTS_DIR/git_output.xml"

echo "Testing Git repository integration..."

# Skip test if git not available
if ! command -v git &>/dev/null; then
    echo "Git not available, skipping test"
    exit 0
fi

# Run files2xml with the Git repository
"$SCRIPT" --gitdir "$GIT_REPO" > "$OUTPUT_FILE"
test_status=$?

# Check if the command ran successfully
assert_equals 0 $test_status "files2xml with Git repo should exit with status 0"

# Check if the output file exists and is valid XML
assert_file_exists "$OUTPUT_FILE" "Output file should be created"
validate_xml "$OUTPUT_FILE" || exit 1

# Check if the Git-tracked file is included
check_file_in_xml "$OUTPUT_FILE" "git_file.txt" || {
    echo "Failed to find git_file.txt in the XML output"
    exit 1
}

# Try with a non-existent Git repository (should fail)
"$SCRIPT" --gitdir "/nonexistent/repo" > "$RESULTS_DIR/git_error.xml" 2>/dev/null
test_status=$?

# Should exit with non-zero status
if [[ $test_status -eq 0 ]]; then
    echo "Failed: files2xml should fail with non-existent Git repository"
    exit 1
fi

echo "Git integration test completed successfully"
exit 0