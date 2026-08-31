#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""
Check that changed AsciiDoc pages carry a valid, current :revdate: field.

Scope is a path rule: only files under en/modules/*/pages/ are checked.
Everything else (nav files, _attributes.adoc, partials/, branding/, README)
is out of scope by construction. Partials are excluded deliberately: an
attribute entry inside an included file overrides the same attribute in the
including page, so a :revdate: in a partial is actively wrong.

A file under pages/ with no level-1 heading also fails. Antora publishes every
.adoc under pages/, so such a file becomes a titleless orphan page at its own
URL; it is an include fragment that belongs in the module's partials/.

A page fails if its :revdate::
  - is missing
  - is not YYYY-MM-DD
  - is not a real calendar date
  - has no paired ":page-revdate: {revdate}"
  - is more than --grace-days older than the file's last change in git
  - is in the future

Errors are reported as GitHub Actions annotations and exit 1.

Usage:
    uv run scripts/check_revdate.py [--grace-days N] [--base-ref REF] [PATH ...]
"""

import argparse
import os
import re
import subprocess
import sys
from datetime import date, datetime, timedelta
from pathlib import Path

# Only pages are checked. "*" is the module name, e.g. en/modules/administration/pages/.
SCOPE_GLOB = "en/modules/*/pages/"

REVDATE_RE = re.compile(r"^:revdate:(?P<value>.*)$", re.MULTILINE)
PAGE_REVDATE_RE = re.compile(r"^:page-revdate:(?P<value>.*)$", re.MULTILINE)
ISO_DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
DOC_TITLE_RE = re.compile(r"^= \S", re.MULTILINE)

PAGE_REVDATE_EXPECTED = "{revdate}"


def github_annotation(level, file_path, line, message):
    """Emit a GitHub Actions annotation, or a plain line when running locally."""
    if os.environ.get("GITHUB_ACTIONS") == "true":
        print(f"::{level} file={file_path},line={line}::{message}")
    else:
        print(f"{level}: {file_path}:{line}: {message}")


def in_scope(rel_path):
    """True if a repo-relative path is an AsciiDoc page we enforce revdate on."""
    parts = Path(rel_path).parts
    if not rel_path.endswith(".adoc"):
        return False
    # en / modules / <module> / pages / ...
    if len(parts) < 5:
        return False
    if parts[0] != "en" or parts[1] != "modules" or parts[3] != "pages":
        return False
    return True


def run_git(args, cwd):
    """Run a git command, returning stdout or None if it failed."""
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
    """
    Last date the file's content changed, per git.

    Uses the author date (%ad), not the committer date: a rebase rewrites
    committer dates, which would make an untouched page look freshly modified
    and fail the grace-period check for no reason.
    """
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
    """1-based line number of the first line starting with needle, else 1."""
    for i, line in enumerate(content.split("\n"), 1):
        if line.startswith(needle):
            return i
    return 1


def is_include_fragment(content):
    """
    True if the file has no document title, meaning it is included into a page
    rather than being one. Such files must not carry a :revdate:, because the
    attribute entry would override the including page's own value.
    """
    return DOC_TITLE_RE.search(content) is None


def check_file(rel_path, repo_root, grace_days, today):
    """
    Validate one page.

    Returns a list of (line_number, message) errors; empty means the page is
    fine.
    """
    full_path = repo_root / rel_path
    content = full_path.read_text(encoding="utf-8")

    # Antora publishes every .adoc under pages/, so a file with no document
    # title becomes a titleless orphan page at its own URL. That is a real bug
    # rather than a file to skip: it is exactly how
    # administration/pages/image-mgmt-container-inspection.adoc came to be
    # published twice. Include fragments belong in the module's partials/.
    if is_include_fragment(content):
        return [
            (
                1,
                "no document title: Antora would publish this as a titleless "
                "page of its own. If it is an include fragment, move it to the "
                "module's partials/ directory",
            )
        ]

    revdate_match = REVDATE_RE.search(content)
    if revdate_match is None:
        return [(1, "missing :revdate: field")]

    line_num = find_line(content, ":revdate:")
    raw = revdate_match.group("value").strip()

    if not ISO_DATE_RE.match(raw):
        return [
            (line_num, f"revdate {raw!r} does not follow the YYYY-MM-DD format")
        ]

    try:
        revdate = datetime.strptime(raw, "%Y-%m-%d").date()
    except ValueError:
        return [(line_num, f"revdate {raw!r} is not a real calendar date")]

    errors = []

    # One day of slack: the runner's clock is UTC, so an author ahead of UTC who
    # stamps their own local date would otherwise be told it is in the future.
    if revdate > today + timedelta(days=1):
        errors.append(
            (line_num, f"revdate ({revdate}) is in the future (today is {today} UTC)")
        )

    page_revdate_match = PAGE_REVDATE_RE.search(content)
    if page_revdate_match is None:
        errors.append(
            (
                line_num,
                f"missing ':page-revdate: {PAGE_REVDATE_EXPECTED}' next to :revdate:",
            )
        )
    elif page_revdate_match.group("value").strip() != PAGE_REVDATE_EXPECTED:
        errors.append(
            (
                find_line(content, ":page-revdate:"),
                f"page-revdate must be exactly {PAGE_REVDATE_EXPECTED!r}, "
                f"got {page_revdate_match.group('value').strip()!r}",
            )
        )

    git_date = get_git_last_modified_date(rel_path, repo_root)
    if git_date is not None and (git_date - revdate) > timedelta(days=grace_days):
        days = (git_date - revdate).days
        errors.append(
            (
                line_num,
                f"revdate ({revdate}) is stale: the page was last changed on "
                f"{git_date}, {days} days later (grace period is {grace_days} days)",
            )
        )

    return errors


def resolve_base_ref(explicit, repo_root):
    """
    Work out what to diff against.

    GITHUB_BASE_REF is set-but-empty on non-pull_request events, so a plain
    os.environ.get(..., default) returns '' and the diff silently compares
    HEAD to itself. Treat empty as unset.
    """
    if explicit:
        return explicit

    base_ref = os.environ.get("GITHUB_BASE_REF") or ""
    base_ref = base_ref.strip()
    if not base_ref:
        base_ref = "master"

    if not base_ref.startswith("origin/"):
        remote_ref = f"origin/{base_ref}"
        if run_git(["rev-parse", "--verify", "--quiet", remote_ref], cwd=repo_root):
            return remote_ref
    return base_ref


def get_changed_files(base_ref, repo_root):
    """Repo-relative paths added or modified relative to the merge base."""
    # R is included deliberately: git detects renames by default, so a page moved
    # and edited in the same commit is reported as R, not M, and would otherwise
    # skip the check entirely. With --name-only, git prints the destination path.
    out = run_git(
        ["diff", "--name-only", "--diff-filter=AMR", f"{base_ref}...HEAD"],
        cwd=repo_root,
    )
    if out is None:
        print(
            f"error: could not diff against {base_ref!r}; "
            "is the branch fetched with enough history?",
            file=sys.stderr,
        )
        sys.exit(2)
    return [line.strip() for line in out.splitlines() if line.strip()]


def main():
    parser = argparse.ArgumentParser(
        description="Check :revdate: on changed AsciiDoc pages"
    )
    parser.add_argument(
        "--grace-days",
        type=int,
        default=7,
        help="how far the revdate may lag the last change, in days (default: 7)",
    )
    parser.add_argument(
        "--base-ref",
        default=None,
        help="ref to diff against (default: $GITHUB_BASE_REF, else origin/master)",
    )
    parser.add_argument(
        "paths",
        nargs="*",
        help="explicit paths to check; bypasses git diff discovery",
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
                print(f"error: {raw} is outside the repository", file=sys.stderr)
                sys.exit(2)
    else:
        base_ref = resolve_base_ref(args.base_ref, repo_root)
        candidates = get_changed_files(base_ref, repo_root)

    pages = [
        p for p in candidates if in_scope(p) and (repo_root / p).exists()
    ]

    # A path the user typed is meant to be checked, so a typo or an out-of-scope
    # file has to be an error. Silently dropping it would report success for a
    # file that was never opened. Paths discovered from a diff are different:
    # most of them are legitimately out of scope and are meant to be ignored.
    if args.paths:
        unchecked = sorted(set(candidates) - set(pages))
        if unchecked:
            for rel_path in unchecked:
                reason = (
                    "does not exist"
                    if not (repo_root / rel_path).exists()
                    else f"is not under {SCOPE_GLOB}"
                )
                print(f"error: {rel_path} {reason}", file=sys.stderr)
            return 2

    if not pages:
        print(f"No AsciiDoc pages under {SCOPE_GLOB} to check.")
        return 0

    print(
        f"Checking {len(pages)} page(s) under {SCOPE_GLOB} "
        f"(grace period: {args.grace_days} days)..."
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
        print(f"Found {error_count} error(s).")
        print(
            "Update :revdate: to the date you changed the page, and keep "
            f"':page-revdate: {PAGE_REVDATE_EXPECTED}' on the line below it."
        )
        return 1

    print(f"All {len(pages)} checked page(s) have a valid revdate.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
