#!/bin/bash
# Test attribute-based XML structure

# Source the test helpers
source "$(dirname "$0")/test_helpers.sh"

# Test file paths
TEST_TEXT_FILE="$TEST_FILES/text.txt"
OUTPUT_FILE="$RESULTS_DIR/attribute_structure.xml"

echo "Testing attribute-based XML structure..."

# Run files2xml with a simple text file
"$SCRIPT" "$TEST_TEXT_FILE" > "$OUTPUT_FILE"
assert_equals 0 $? "files2xml should exit with status 0"

# Check if the output file exists and is valid XML
assert_file_exists "$OUTPUT_FILE" "Output file should be created"
validate_xml "$OUTPUT_FILE" || exit 1

# Check for attribute-based structure
grep -q "<file fqfn=" "$OUTPUT_FILE" || {
    echo "Failed: attribute-based file structure not found"
    exit 1
}

# FQFN should end with the filename
grep -q "fqfn=\".*text.txt\"" "$OUTPUT_FILE" || {
    echo "Failed: fqfn attribute not found or doesn't end with filename"
    exit 1
}

grep -q "type=\"text/plain\"" "$OUTPUT_FILE" || {
    echo "Failed: type attribute not found"
    exit 1
}

grep -q "size=\"" "$OUTPUT_FILE" || {
    echo "Failed: size attribute not found"
    exit 1
}

grep -q "modified=\"" "$OUTPUT_FILE" || {
    echo "Failed: modified attribute not found"
    exit 1
}

# Verify all metadata is in attributes, not in child elements
if grep -q "<fqfn>" "$OUTPUT_FILE"; then
    echo "Failed: Found <fqfn> child element instead of attribute"
    exit 1
fi

if grep -q "<n>" "$OUTPUT_FILE"; then
    echo "Failed: Found <n> child element instead of attribute"
    exit 1
fi

if grep -q "<type>" "$OUTPUT_FILE"; then
    echo "Failed: Found <type> child element instead of attribute"
    exit 1
fi

if grep -q "<size>" "$OUTPUT_FILE"; then
    echo "Failed: Found <size> child element instead of attribute"
    exit 1
fi

if grep -q "<modified>" "$OUTPUT_FILE"; then
    echo "Failed: Found <modified> child element instead of attribute"
    exit 1
fi

# But content should still be a child element
grep -q "<content>" "$OUTPUT_FILE" || {
    echo "Failed: <content> child element not found"
    exit 1
}

echo "Attribute structure test completed successfully"
exit 0