#!/bin/bash

# File name of the changelog
CHANGELOG_FILE=".changelog"

# Extracts the section of the changelog from the start of the file 
# to the first occurrence of a dashed line.
extract_latest_changelog() {
    # Use awk to extract the text between two patterns
    # Here, it extracts text from the beginning of the file to the first dashed line
    awk '/^---$/{exit} {print}' $CHANGELOG_FILE
}

# Call the function and store the result
LATEST_CHANGELOG=$(extract_latest_changelog)

# Output the result
echo "$LATEST_CHANGELOG"