#!/usr/bin/env bash

# Find all .adoc files under en/modules, excluding Antora nav files (nav-*.adoc)
find en/modules -type f -name "*.adoc" ! -name "nav-*.adoc" | while read -r ADOC; do
  # Remove any lines with :revdate: or :page-revdate: (anywhere in the file)
  sed -i '/^:revdate:/d;/^:page-revdate:/d' "$ADOC"
  echo "Removed revdate and page-revdate from $ADOC"
done

