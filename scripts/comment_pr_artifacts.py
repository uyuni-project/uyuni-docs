#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Comment on pull requests with links to CI build artifacts."""

import argparse
import json
import os
import re
import subprocess
import sys
import time
from typing import Any, Dict, List, Optional, Tuple

COMMENT_MARKER = "<!-- uyuni-docs-pr-artifacts -->"

# Known artifact grouping and metadata
ARTIFACT_GROUPS = [
    {
        "title": "Uyuni Documentation",
        "artifacts": [
            {
                "name": "uyuni-docs-html",
                "label": "HTML Documentation (ZIP)",
                "icon": "🌐",
            },
            {
                "name": "uyuni-docs-pdf-en",
                "label": "PDF Documentation (English, ZIP)",
                "icon": "📄",
            },
        ],
    },
    {
        "title": "SUSE Multi-Linux Manager Documentation",
        "artifacts": [
            {
                "name": "mlm-docs-html",
                "label": "HTML Documentation (ZIP)",
                "icon": "🌐",
            },
            {
                "name": "mlm-docs-pdf-en",
                "label": "PDF Documentation (English, ZIP)",
                "icon": "📄",
            },
        ],
    },
]


def run_command(
    cmd: List[str], input_data: Optional[str] = None
) -> Tuple[str, int, str]:
    """Execute a shell command via subprocess safely."""
    try:
        res = subprocess.run(
            cmd,
            input=input_data,
            capture_output=True,
            text=True,
            check=False,
        )
        return res.stdout, res.returncode, res.stderr
    except Exception as e:
        return "", 1, str(e)


def format_size(size_bytes: int) -> str:
    """Format bytes into a human-readable size string."""
    if size_bytes < 1024:
        return f"{size_bytes} B"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.1f} KB"
    elif size_bytes < 1024 * 1024 * 1024:
        return f"{size_bytes / (1024 * 1024):.1f} MB"
    else:
        return f"{size_bytes / (1024 * 1024 * 1024):.2f} GB"


def is_pr_open(pr_number: str, repo: str) -> bool:
    """Check if the target PR is currently open."""
    stdout, code, stderr = run_command([
        "gh", "pr", "view", str(pr_number), "--repo", repo, "--json", "state"
    ])
    if code != 0:
        if "403" in stderr or "Resource not accessible by integration" in stderr:
            print(
                f"Notice: Cannot query PR state for #{pr_number} (insufficient permissions).",
                file=sys.stderr,
            )
        else:
            print(f"Warning: Failed to view PR state: {stderr}", file=sys.stderr)
        return True  # Proceed cautiously if query fails

    try:
        data = json.loads(stdout)
        state = data.get("state")
        if state and state != "OPEN":
            print(f"PR #{pr_number} state is '{state}'. Skipping comment.")
            return False
    except Exception as e:
        print(f"Warning: Failed to parse PR state JSON: {e}", file=sys.stderr)
    return True


def fetch_artifacts(
    repo: str, run_id: str, retries: int = 3, retry_delay: float = 2.0
) -> List[Dict[str, Any]]:
    """Fetch artifacts for a specific workflow run using the GitHub API."""
    endpoint = f"repos/{repo}/actions/runs/{run_id}/artifacts"
    for attempt in range(retries):
        stdout, code, stderr = run_command(["gh", "api", endpoint])
        if code == 0 and stdout:
            try:
                data = json.loads(stdout)
                artifacts = data.get("artifacts", [])
                if artifacts or attempt == retries - 1:
                    return artifacts
            except Exception as e:
                print(f"Warning: Failed to parse artifacts JSON: {e}", file=sys.stderr)
        if attempt < retries - 1:
            time.sleep(retry_delay)
    return []


def generate_comment_body(
    repo: str,
    run_id: str,
    commit_sha: Optional[str],
    artifacts: List[Dict[str, Any]],
) -> str:
    """Construct the markdown comment body containing artifact links."""
    artifacts_by_name = {a["name"]: a for a in artifacts if "name" in a}
    run_url = f"https://github.com/{repo}/actions/runs/{run_id}"

    if commit_sha:
        short_sha = commit_sha[:7]
        commit_link = f"[`{short_sha}`](https://github.com/{repo}/commit/{commit_sha})"
    else:
        commit_link = "latest commit"

    lines = [
        COMMENT_MARKER,
        "## 📚 Documentation build artifacts",
        "",
        f"Documentation build artifacts for {commit_link} in CI workflow run [#{run_id}]({run_url}):",
        "",
    ]

    matched_names = set()

    for group in ARTIFACT_GROUPS:
        group_lines = []
        for item in group["artifacts"]:
            name = item["name"]
            if name in artifacts_by_name:
                matched_names.add(name)
                art = artifacts_by_name[name]
                art_id = art.get("id")
                size = format_size(art.get("size_in_bytes", 0))
                download_url = f"https://github.com/{repo}/actions/runs/{run_id}/artifacts/{art_id}"
                icon = item.get("icon", "📦")
                label = item.get("label", name)
                group_lines.append(f"- {icon} [{label}]({download_url}) ({size})")

        if group_lines:
            lines.append(f"### {group['title']}")
            lines.extend(group_lines)
            lines.append("")

    # Additional artifacts not in predefined groups
    extra_lines = []
    for art in artifacts:
        name = art.get("name", "")
        if name and name not in matched_names:
            art_id = art.get("id")
            size = format_size(art.get("size_in_bytes", 0))
            download_url = f"https://github.com/{repo}/actions/runs/{run_id}/artifacts/{art_id}"
            extra_lines.append(f"- 📦 [{name}]({download_url}) ({size})")

    if extra_lines:
        lines.append("### Additional Artifacts")
        lines.extend(extra_lines)
        lines.append("")

    lines.extend([
        "---",
        "> ℹ️ **Download note:** GitHub requires you to be logged in to download CI artifacts.",
        "> Extract the HTML archive to view documentation in your browser. Artifacts are automatically expired by GitHub after 1 day.",
    ])

    return "\n".join(lines)


def find_existing_comment_id(pr_number: str, repo: str) -> Optional[str]:
    """Find the database ID of an existing preview comment on the PR."""
    stdout, code, stderr = run_command([
        "gh", "pr", "view", str(pr_number), "--repo", repo, "--json", "comments"
    ])
    if code != 0 or not stdout:
        return None

    try:
        data = json.loads(stdout)
        for comment in data.get("comments", []):
            body = comment.get("body", "")
            if COMMENT_MARKER in body or "## 📚 Documentation build artifacts" in body:
                url = comment.get("url", "")
                match = re.search(r"\d+$", url)
                if match:
                    return match.group(0)
    except Exception as e:
        print(f"Warning: Failed to parse PR comments: {e}", file=sys.stderr)
    return None


def post_or_update_comment(
    pr_number: str,
    repo: str,
    body: str,
    dry_run: bool = False,
) -> bool:
    """Create a new comment or update the existing one on the PR."""
    if dry_run:
        print("=== DRY RUN: Comment Body ===")
        print(body)
        print("=============================")
        return True

    comment_id = find_existing_comment_id(pr_number, repo)
    payload = json.dumps({"body": body})

    if comment_id:
        print(f"Updating existing documentation artifact comment (ID: {comment_id}) on PR #{pr_number}...")
        endpoint = f"repos/{repo}/issues/comments/{comment_id}"
        cmd = ["gh", "api", "-X", "PATCH", endpoint, "--input", "-"]
    else:
        print(f"Creating new documentation artifact comment on PR #{pr_number}...")
        endpoint = f"repos/{repo}/issues/{pr_number}/comments"
        cmd = ["gh", "api", "-X", "POST", endpoint, "--input", "-"]

    stdout, code, stderr = run_command(cmd, input_data=payload)
    if code != 0:
        if "Resource not accessible by integration" in stderr or "403" in stderr:
            print(
                f"Notice: Insufficient permissions to post/update comment on PR #{pr_number} "
                f"(token is read-only, which is standard for pull requests from forks). Skipping comment.",
                file=sys.stderr,
            )
            return True
        print(f"Error: Failed to post/update comment: {stderr}", file=sys.stderr)
        return False

    print("Successfully posted/updated comment.")
    return True


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Comment on PR with links to documentation build artifacts."
    )
    parser.add_argument(
        "--pr",
        dest="pr_number",
        default=os.environ.get("GITHUB_PR_NUMBER"),
        help="Target pull request number (or via GITHUB_PR_NUMBER env var)",
    )
    parser.add_argument(
        "--run-id",
        dest="run_id",
        default=os.environ.get("GITHUB_RUN_ID"),
        help="GitHub Actions run ID (or via GITHUB_RUN_ID env var)",
    )
    parser.add_argument(
        "--repo",
        dest="repo",
        default=os.environ.get("GITHUB_REPOSITORY", "uyuni-project/uyuni-docs"),
        help="Repository name (e.g. uyuni-project/uyuni-docs)",
    )
    parser.add_argument(
        "--commit",
        dest="commit_sha",
        default=os.environ.get("GITHUB_SHA"),
        help="Commit SHA (optional, or via GITHUB_SHA env var)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print comment body without posting or editing comments",
    )

    args = parser.parse_args()

    if not args.pr_number:
        print("Error: --pr is required (or set GITHUB_PR_NUMBER).", file=sys.stderr)
        return 1
    if not args.run_id:
        print("Error: --run-id is required (or set GITHUB_RUN_ID).", file=sys.stderr)
        return 1

    if not args.dry_run and not is_pr_open(args.pr_number, args.repo):
        return 0

    artifacts = fetch_artifacts(args.repo, args.run_id)
    if not artifacts:
        print(f"No artifacts found for workflow run {args.run_id}. Skipping comment.")
        return 0

    body = generate_comment_body(args.repo, args.run_id, args.commit_sha, artifacts)
    success = post_or_update_comment(args.pr_number, args.repo, body, dry_run=args.dry_run)
    return 0 if success else 1


if __name__ == "__main__":
    sys.exit(main())
