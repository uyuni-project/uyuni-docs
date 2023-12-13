#!/bin/bash

# Path to the file containing the release notes
FILE_PATH=".changelog"

# Function to extract release notes
extract_release_notes() {
    # Use awk to extract the text between two dashed lines
    awk '/^---+$/{flag=!flag;next} flag' "$FILE_PATH"
}

# Call the function and store the result
RELEASE_NOTES=$(extract_release_notes)

# Output the result
echo "$RELEASE_NOTES"