#!/bin/bash

# Path to the file containing the release notes
FILE_PATH=".changelog"

# Function to extract release notes
extract_release_notes() {
    # Use awk to extract the text between two sets of dashed lines
    awk '/^---+$/{flag=!flag;next} flag' "$FILE_PATH"
}

# Call the function and output the result
extract_release_notes