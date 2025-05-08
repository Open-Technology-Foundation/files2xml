#!/bin/bash
# Helper functions for the test scripts

# Get the absolute path to the script directory
TEST_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

# Path to the files2xml script
SCRIPT="$(dirname "$TEST_DIR")/files2xml"

# Directory for test files
TEST_FILES="$TEST_DIR/testfiles"

# Directory for test results
RESULTS_DIR="$TEST_DIR/results"
mkdir -p "$RESULTS_DIR"

# XML validation function using xmllint
validate_xml() {
    local xml_file="$1"
    
    if command -v xmllint &>/dev/null; then
        if xmllint --noout "$xml_file" 2>/dev/null; then
            return 0
        else
            echo "XML validation failed for $xml_file"
            return 1
        fi
    else
        echo "Warning: xmllint not available, skipping XML validation"
        return 0
    fi
}

# Count elements in an XML file
count_elements() {
    local xml_file="$1"
    local element_name="$2"
    
    if command -v xmllint &>/dev/null; then
        local count
        count=$(xmllint --xpath "count(//${element_name})" "$xml_file" 2>/dev/null)
        echo "$count"
    else
        echo "Warning: xmllint not available, using grep for counting"
        grep -o "<$element_name" "$xml_file" | wc -l
    fi
}

# Run the files2xml script with given options
run_files2xml() {
    local options=("$@")
    local output_file="$RESULTS_DIR/output.xml"
    
    "$SCRIPT" "${options[@]}" > "$output_file"
    local status=$?
    
    echo "Output saved to: $output_file"
    echo "Exit status: $status"
    
    # Return the script's exit status
    return $status
}

# Check if a file exists in XML output
check_file_in_xml() {
    local xml_file="$1"
    local file_name="$2"
    
    # Now check for the filename in the fqfn attribute
    grep -q "fqfn=\".*/$file_name\"" "$xml_file"
    return $?
}

# Get the size of a file in bytes
get_file_size() {
    stat -c %s "$1"
}

# Clean up temporary test files
cleanup_temp_files() {
    rm -f "$RESULTS_DIR/tmp_*" 2>/dev/null
}

# Test assertion functions
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Values should be equal}"
    
    if [[ "$expected" == "$actual" ]]; then
        echo "✓ PASS: $message (Expected: $expected, Actual: $actual)"
        return 0
    else
        echo "✗ FAIL: $message (Expected: $expected, Actual: $actual)"
        return 1
    fi
}

assert_not_equals() {
    local unexpected="$1"
    local actual="$2"
    local message="${3:-Values should not be equal}"
    
    if [[ "$unexpected" != "$actual" ]]; then
        echo "✓ PASS: $message (Unexpected: $unexpected, Actual: $actual)"
        return 0
    else
        echo "✗ FAIL: $message (Values should differ but both are: $actual)"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"
    
    if [[ "$haystack" == *"$needle"* ]]; then
        echo "✓ PASS: $message (Found substring: $needle)"
        return 0
    else
        echo "✗ FAIL: $message (Substring not found: $needle)"
        return 1
    fi
}

assert_file_exists() {
    local file="$1"
    local message="${2:-File should exist}"
    
    if [[ -f "$file" ]]; then
        echo "✓ PASS: $message (File exists: $file)"
        return 0
    else
        echo "✗ FAIL: $message (File does not exist: $file)"
        return 1
    fi
}

assert_greater_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value should be greater than threshold}"
    
    if (( value > threshold )); then
        echo "✓ PASS: $message (Value $value > Threshold $threshold)"
        return 0
    else
        echo "✗ FAIL: $message (Value $value is not > Threshold $threshold)"
        return 1
    fi
}

assert_less_than() {
    local value="$1"
    local threshold="$2"
    local message="${3:-Value should be less than threshold}"
    
    if (( value < threshold )); then
        echo "✓ PASS: $message (Value $value < Threshold $threshold)"
        return 0
    else
        echo "✗ FAIL: $message (Value $value is not < Threshold $threshold)"
        return 1
    fi
}

# Register cleanup function to run on script exit
trap cleanup_temp_files EXIT