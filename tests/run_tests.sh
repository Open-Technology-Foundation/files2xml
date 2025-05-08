#!/bin/bash
# Main test script for files2xml
# Run all tests and collect results

set -euo pipefail

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Directory containing the test scripts
TEST_DIR="$(dirname "$(readlink -f "$0")")"
SCRIPT_PATH="$(dirname "$TEST_DIR")/files2xml"

# Make sure the script is executable
chmod +x "$SCRIPT_PATH"

# Initialize counters
declare -i TESTS_TOTAL=0
declare -i TESTS_PASSED=0
declare -i TESTS_FAILED=0

# Output directory for test results
OUTPUT_DIR="$TEST_DIR/results"
mkdir -p "$OUTPUT_DIR"

# Log file for detailed test output
LOG_FILE="$OUTPUT_DIR/test_log.txt"
> "$LOG_FILE"  # Clear log file

# Function to run a test and check its result
run_test() {
    local test_name=$1
    local test_script=$2
    local expected_status=${3:-0}  # Expected status code, default 0

    echo -e "${YELLOW}Running test: $test_name${NC}" | tee -a "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    
    # Run the test
    TESTS_TOTAL=$((TESTS_TOTAL + 1))
    
    if bash "$test_script" >> "$LOG_FILE" 2>&1; then
        test_status=$?
        if [[ $test_status -eq $expected_status ]]; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}✓ PASSED${NC}: $test_name" | tee -a "$LOG_FILE"
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
            echo -e "${RED}✗ FAILED${NC}: $test_name (Expected status $expected_status, got $test_status)" | tee -a "$LOG_FILE"
        fi
    else
        test_status=$?
        if [[ $test_status -eq $expected_status ]]; then
            TESTS_PASSED=$((TESTS_PASSED + 1))
            echo -e "${GREEN}✓ PASSED${NC}: $test_name (Expected non-zero status $expected_status)" | tee -a "$LOG_FILE"
        else
            TESTS_FAILED=$((TESTS_FAILED + 1))
            echo -e "${RED}✗ FAILED${NC}: $test_name (Expected status $expected_status, got $test_status)" | tee -a "$LOG_FILE"
        fi
    fi
    
    echo "" >> "$LOG_FILE"
}

# Find and run all test_*.sh files in the tests directory
echo -e "${YELLOW}Starting tests...${NC}"
for test_file in "$TEST_DIR"/test_*.sh; do
    if [[ -f "$test_file" ]]; then
        test_name=$(basename "$test_file" .sh)
        run_test "$test_name" "$test_file"
    fi
done

# Display summary
echo -e "\n${YELLOW}Test Summary${NC}"
echo -e "----------------------------------------"
echo -e "Total tests: $TESTS_TOTAL"
echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}Some tests failed. Check $LOG_FILE for details.${NC}"
    exit 1
fi