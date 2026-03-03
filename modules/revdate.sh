#!/usr/bin/env bash

# Find all .adoc files excluding Antora nav files (nav-*.adoc)
find . -type f -name "*.adoc" ! -name "nav-*.adoc" | while read -r ADOC; do
  echo "Processing $ADOC ..."
  
  # Get last commit date
  RDATE=$(git --no-pager log -1 --format="%cd" --date='format:%Y-%m-%d' "$ADOC")
  
  # Remove existing attributes (cleanup old wrong placements)
  sed -i '/^:revdate:/d;/^:page-revdate:/d' "$ADOC"
  
  # Find the first level-1 heading (= ...)
  LINE_NUM=$(grep -n "^[=] " "$ADOC" | head -n 1 | cut -d: -f1)

  if [[ -n "$LINE_NUM" ]]; then
    # Insert attributes right after the first heading
    sed -i "${LINE_NUM}a :revdate: $RDATE\n:page-revdate: {revdate}" "$ADOC"
    echo "Inserted attributes after first section title in $ADOC"
  else
    echo "No level-1 heading found in $ADOC (skipped)"
  fi
done

