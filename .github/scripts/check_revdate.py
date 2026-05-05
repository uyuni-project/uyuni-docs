#!/usr/bin/env python3
"""
Check that .adoc files have a valid :revdate: field.

This script validates:
1. All .adoc files contain a :revdate: field
2. The date follows the YYYY-MM-DD format
3. The revdate is updated when the file content is modified

Only checks files that have been added or modified in the current branch.
Outputs GitHub Actions annotations for errors and warnings.

Usage:
    check_revdate.py [--grace-days DAYS] [--exclude-patterns PATTERN ...]

Options:
    --grace-days DAYS                    Grace period in days for revdate (default: 7)
    --exclude-patterns PATTERN [...]     Space-separated filename patterns to exclude
                                         (default: _attributes.adoc attributes- nav- README.adoc workflow-)
"""

import os
import re
import sys
import subprocess
import argparse
from datetime import datetime
from pathlib import Path


def github_annotation(level, file_path, line, message):
    """
    Output a GitHub Actions annotation.

    Args:
        level: 'error', 'warning', or 'notice'
        file_path: relative file path
        line: line number (or 1 if unknown)
        message: the annotation message
    """
    print(f"::{level} file={file_path},line={line}::{message}")


def get_git_last_modified_date(file_path):
    """Get the last modification date of a file from git history."""
    try:
        result = subprocess.run(
            ['git', 'log', '-1', '--format=%ci', '--', file_path],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=True
        )
        if result.stdout.strip():
            date_str = result.stdout.strip().split()[0]
            return datetime.strptime(date_str, '%Y-%m-%d').date()
        return None
    except subprocess.CalledProcessError:
        return None


def find_revdate_line(content):
    """Find the line number of the :revdate: field."""
    lines = content.split('\n')
    for i, line in enumerate(lines, 1):
        if line.strip().startswith(':revdate:'):
            return i
    return 1


def check_revdate(file_path, grace_days=7):
    """
    Check if a .adoc file has a valid :revdate: field.

    Args:
        file_path: Path to the .adoc file
        grace_days: Grace period in days for outdated revdate

    Returns:
        tuple: (is_valid, level, line_number, error_message)
               level is 'error' or 'warning'
    """
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    revdate_pattern = r'^:revdate:\s*(\d{4}-\d{2}-\d{2})\s*$'
    match = re.search(revdate_pattern, content, re.MULTILINE)

    line_num = find_revdate_line(content)

    if not match:
        wrong_format = re.search(r'^:revdate:', content, re.MULTILINE)
        if wrong_format:
            return False, 'error', line_num, "revdate field exists but doesn't follow YYYY-MM-DD format"
        return False, 'warning', 1, "missing :revdate: field"

    date_str = match.group(1)
    try:
        revdate = datetime.strptime(date_str, '%Y-%m-%d').date()
    except ValueError:
        return False, 'error', line_num, f"invalid date format: {date_str}"

    git_date = get_git_last_modified_date(file_path)
    if git_date:
        days_diff = (git_date - revdate).days
        if days_diff > grace_days:
            return False, 'error', line_num, f"revdate ({revdate}) is outdated (file last modified: {git_date}, {days_diff} days difference)"

    return True, None, None, None


def get_changed_files(repo_root):
    """Get list of .adoc files that have changed compared to the base branch."""
    try:
        # Try to get the base ref from GitHub environment
        base_ref = os.environ.get('GITHUB_BASE_REF', 'origin/master')
        if base_ref and not base_ref.startswith('origin/'):
            base_ref = f'origin/{base_ref}'

        result = subprocess.run(
            ['git', 'diff', '--name-only', '--diff-filter=AM', f'{base_ref}...HEAD'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=True,
            cwd=repo_root
        )
        changed_files = [
            repo_root / f.strip()
            for f in result.stdout.strip().split('\n')
            if f.strip().endswith('.adoc')
        ]
        return [f for f in changed_files if f.exists()]
    except subprocess.CalledProcessError:
        return []


def main():
    """Main function to check changed .adoc files."""
    parser = argparse.ArgumentParser(description='Check revdate in .adoc files')
    parser.add_argument('--grace-days', type=int, default=7,
                        help='Grace period in days for outdated revdate (default: 7)')
    parser.add_argument('--exclude-patterns', nargs='*',
                        default=['_attributes.adoc', 'attributes-', 'nav-', 'README.adoc', 'workflow-'],
                        help='Space-separated filename patterns to exclude')
    args = parser.parse_args()

    repo_root = Path(__file__).parent.parent.parent

    excluded_patterns = set(args.exclude_patterns)

    def should_exclude(file_path):
        """Check if a file should be excluded."""
        return any(pattern in file_path.name for pattern in excluded_patterns)

    changed_files = get_changed_files(repo_root)
    adoc_files = [f for f in changed_files if not should_exclude(f)]

    if not changed_files:
        print("✅ No .adoc files changed in this PR")
        sys.exit(0)
    elif not adoc_files:
        print(f"✅ All {len(changed_files)} changed .adoc file(s) are excluded (nav, attributes, etc.)")
        sys.exit(0)

    print(f"Checking {len(adoc_files)} changed .adoc file(s) (grace period: {args.grace_days} days)...")

    error_count = 0
    warning_count = 0

    for file_path in adoc_files:
        relative_path = file_path.relative_to(repo_root)
        is_valid, level, line_num, error_msg = check_revdate(file_path, args.grace_days)

        if not is_valid:
            if level == 'error':
                error_count += 1
            else:
                warning_count += 1

            github_annotation(level, str(relative_path), line_num, error_msg)

    print()
    if error_count > 0:
        print(f"❌ Found {error_count} error(s) and {warning_count} warning(s)")
        sys.exit(1)
    elif warning_count > 0:
        print(f"⚠️  Found {warning_count} warning(s), but no critical errors")
        print("✅ All checked files passed")
    else:
        print("✅ All .adoc files have valid revdate fields!")

    sys.exit(0)


if __name__ == '__main__':
    main()
