#!/bin/bash

# Path to the changelog file
CHANGELOG_FILE="CHANGELOG.md"

# Function to extract release notes for a specific version
extract_release_notes() {
    local version=$1
    awk "/# ${version}/,/^# /{if (!/^# ${version}/) print}" $CHANGELOG_FILE
}

# Check if a version argument was provided
if [ $# -eq 0 ]
then
    echo "No version argument supplied"
    exit 1
fi

# Call the function with the version as argument
extract_release_notes "$1"
