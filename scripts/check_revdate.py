#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Check :revdate: on changed AsciiDoc pages."""

import argparse
import os
import re
import subprocess
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

# "*" is the name of the module.
SCOPE_GLOB = "en/modules/*/pages/"

REVDATE_RE = re.compile(r"^:revdate:(?P<value>.*)$", re.MULTILINE)
PAGE_REVDATE_RE = re.compile(r"^:page-revdate:(?P<value>.*)$", re.MULTILINE)
ISO_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
DOC_TITLE_RE = re.compile(r"^= \S", re.MULTILINE)

PAGE_REVDATE_EXPECTED = "{revdate}"

# This branch is manager-5.2.
DEFAULT_BASE_REF = "manager-5.2"


def github_annotation(level, file_path, line, message):
    """Print one error, for CI or locally."""
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print(f"::{level} file={file_path},line={line}::{message}")
    else:
        print(f"{level}: {file_path}:{line}: {message}")


def in_scope(rel_path):
    """Return True for a page in scope."""
    parts = Path(rel_path).parts
    if not rel_path.endswith(".adoc"):
        return False
    # en/modules/<module>/pages/...
    if len(parts) < 5:
        return False
    if parts[0] != "en" or parts[1] != "modules" or parts[3] != "pages":
        return False
    return True


def run_git(args, cwd):
    """Run git. Return output, or None."""
    try:
        result = subprocess.run(
            ["git"] + args,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            check=True,
            cwd=str(cwd),
        )
    except (subprocess.CalledProcessError, OSError):
        return None
    return result.stdout


def get_git_last_modified_date(rel_path, repo_root):
    """Git author date of the last change."""
    # A rebase rewrites committer dates.
    out = run_git(
        ["log", "-1", "--format=%ad", "--date=format:%Y-%m-%d", "--", str(rel_path)],
        cwd=repo_root,
    )
    if not out or not out.strip():
        return None
    try:
        return datetime.strptime(out.strip(), "%Y-%m-%d").date()
    except ValueError:
        return None


def find_line(content, needle):
    """Return the number of the first match."""
    for i, line in enumerate(content.split("\n"), 1):
        if line.startswith(needle):
            return i
    return 1


def is_include_fragment(content):
    """True if the file has no title."""
    return DOC_TITLE_RE.search(content) is None


def check_file(rel_path, repo_root, grace_days, today):
    """Check one page. Return its errors."""
    full_path = repo_root / rel_path
    content = full_path.read_text(encoding="utf-8")

    if is_include_fragment(content):
        return [
            (
                1,
                "the file has no document title, and Antora publishes it as a "
                "page with no title. Move the file to the partials/ directory "
                "of its module",
            )
        ]

    revdate_match = REVDATE_RE.search(content)
    if revdate_match is None:
        return [(1, "the :revdate: attribute is absent")]

    line_num = find_line(content, ":revdate:")
    raw = revdate_match.group("value").strip()

    if not ISO_DATE_RE.match(raw):
        return [(line_num, f"revdate {raw!r} is not in the YYYY-MM-DD format")]

    try:
        revdate = datetime.strptime(raw, "%Y-%m-%d").date()
    except ValueError:
        return [(line_num, f"revdate {raw!r} is not a correct calendar date")]

    errors = []

    # The clock of the runner is UTC.
    if revdate > today + timedelta(days=1):
        errors.append(
            (line_num, f"revdate ({revdate}) is in the future (today is {today} UTC)")
        )

    page_revdate_match = PAGE_REVDATE_RE.search(content)
    if page_revdate_match is None:
        errors.append(
            (
                line_num,
                f"the ':page-revdate: {PAGE_REVDATE_EXPECTED}' attribute is absent",
            )
        )
    elif page_revdate_match.group("value").strip() != PAGE_REVDATE_EXPECTED:
        errors.append(
            (
                find_line(content, ":page-revdate:"),
                f"page-revdate must be {PAGE_REVDATE_EXPECTED!r}, "
                f"but it is {page_revdate_match.group('value').strip()!r}",
            )
        )

    git_date = get_git_last_modified_date(rel_path, repo_root)
    if git_date is not None and (git_date - revdate) > timedelta(days=grace_days):
        days = (git_date - revdate).days
        errors.append(
            (
                line_num,
                f"revdate ({revdate}) is too old. The last change to the page "
                f"was on {git_date}, {days} days later. The permitted "
                f"difference is {grace_days} days",
            )
        )

    return errors


def resolve_base_ref(explicit, repo_root):
    """Find the ref to compare with."""
    if explicit:
        return explicit

    # Empty, not absent, outside a pull request.
    base_ref = os.environ.get("GITHUB_BASE_REF") or ""
    base_ref = base_ref.strip()
    if not base_ref:
        base_ref = DEFAULT_BASE_REF

    if not base_ref.startswith("origin/"):
        remote_ref = f"origin/{base_ref}"
        if run_git(["rev-parse", "--verify", "--quiet", remote_ref], cwd=repo_root):
            return remote_ref
    return base_ref


def get_changed_files(base_ref, repo_root):
    """Return paths the branch adds or changes."""
    # R: a renamed page must not escape.
    out = run_git(
        ["diff", "--name-only", "--diff-filter=AMR", f"{base_ref}...HEAD"],
        cwd=repo_root,
    )
    if out is None:
        print(
            f"error: cannot compare with {base_ref!r}. "
            "Make sure that the branch has sufficient history.",
            file=sys.stderr,
        )
        sys.exit(2)
    return [line.strip() for line in out.splitlines() if line.strip()]


def main():
    parser = argparse.ArgumentParser(
        description="Check :revdate: on changed AsciiDoc pages",
        epilog="A page fails if its :revdate: is absent, is not in the "
        "YYYY-MM-DD format, is not a correct calendar date, has no paired "
        ":page-revdate:, is in the future, or is more than --grace-days days "
        "older than the last change in git.",
    )
    parser.add_argument(
        "--grace-days",
        type=int,
        default=7,
        help="the permitted number of days between the revdate and the last "
        "change (default: 7)",
    )
    parser.add_argument(
        "--base-ref",
        default=None,
        help="the ref to compare with (default: $GITHUB_BASE_REF, "
        f"or origin/{DEFAULT_BASE_REF})",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="the paths to check; the script then does not use git diff",
    )
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent

    if args.paths:
        candidates = []
        for raw in args.paths:
            path = Path(raw).resolve()
            try:
                candidates.append(str(path.relative_to(repo_root)))
            except ValueError:
                print(f"error: {raw} is not in the repository", file=sys.stderr)
                sys.exit(2)
    else:
        base_ref = resolve_base_ref(args.base_ref, repo_root)
        candidates = get_changed_files(base_ref, repo_root)

    pages = [
        p for p in candidates if in_scope(p) and (repo_root / p).exists()
    ]

    # Do not discard a user-given path.
    if args.paths:
        unchecked = sorted(set(candidates) - set(pages))
        if unchecked:
            for rel_path in unchecked:
                reason = (
                    "does not exist"
                    if not (repo_root / rel_path).exists()
                    else f"is not in {SCOPE_GLOB}"
                )
                print(f"error: {rel_path} {reason}", file=sys.stderr)
            return 2

    if not pages:
        print(f"There are no AsciiDoc pages in {SCOPE_GLOB} to check.")
        return 0

    print(
        f"{len(pages)} page(s) to check in {SCOPE_GLOB} "
        f"(permitted difference: {args.grace_days} days)"
    )

    today = date.today()
    error_count = 0
    for rel_path in sorted(pages):
        for line_num, message in check_file(
            rel_path, repo_root, args.grace_days, today
        ):
            github_annotation("error", rel_path, line_num, message)
            error_count += 1

    print()
    if error_count:
        print(f"The check found {error_count} error(s).")
        print(
            "Set :revdate: to the date of your change. Keep "
            f"':page-revdate: {PAGE_REVDATE_EXPECTED}' on the next line."
        )
        return 1

    print(f"All {len(pages)} page(s) have a correct revdate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
