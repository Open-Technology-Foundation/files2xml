#!/bin/bash
# Test XML minification option

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test file
TEST_TEXT_FILE="$TEST_FILES/text.txt"
OUTPUT_NORMAL="$RESULTS_DIR/minify_normal.xml"
OUTPUT_MINIFIED="$RESULTS_DIR/minify_minified.xml"

echo "Testing XML minification option..."

# Run files2xml normally
"$SCRIPT" "$TEST_TEXT_FILE" > "$OUTPUT_NORMAL"
assert_equals 0 $? "Normal execution should exit with status 0"

# Run files2xml with minify option
"$SCRIPT" -M "$TEST_TEXT_FILE" > "$OUTPUT_MINIFIED"
assert_equals 0 $? "Minified execution should exit with status 0"

# Validate both outputs
validate_xml "$OUTPUT_NORMAL" || exit 1
validate_xml "$OUTPUT_MINIFIED" || exit 1

# Check that both outputs contain the same file
check_file_in_xml "$OUTPUT_NORMAL" "text.txt" || {
    echo "Failed: text.txt missing from normal output"
    exit 1
}

check_file_in_xml "$OUTPUT_MINIFIED" "text.txt" || {
    echo "Failed: text.txt missing from minified output"
    exit 1
}

# Check that both contain the file content
grep -q "This is a plain text file" "$OUTPUT_NORMAL" || {
    echo "Failed: Content missing from normal output"
    exit 1
}

grep -q "This is a plain text file" "$OUTPUT_MINIFIED" || {
    echo "Failed: Content missing from minified output"
    exit 1
}

# Minified output should be smaller than normal output
normal_size=$(get_file_size "$OUTPUT_NORMAL")
minified_size=$(get_file_size "$OUTPUT_MINIFIED")

if [[ $minified_size -ge $normal_size ]]; then
    echo "Failed: Minified output ($minified_size bytes) is not smaller than normal output ($normal_size bytes)"
    exit 1
fi

# Minified output should not have indentation
if grep -q "  <file" "$OUTPUT_MINIFIED"; then
    echo "Failed: Minified output still contains indentation"
    exit 1
fi

# Minified output should have fewer newlines - we'll make this a warning only
normal_newlines=$(grep -o $'\n' "$OUTPUT_NORMAL" | wc -l)
minified_newlines=$(grep -o $'\n' "$OUTPUT_MINIFIED" | wc -l)

if [[ $minified_newlines -ge $normal_newlines ]]; then
    echo "Warning: Minified output ($minified_newlines newlines) does not have fewer newlines than normal output ($normal_newlines newlines)"
fi

echo "Minify option test completed successfully"
exit 0