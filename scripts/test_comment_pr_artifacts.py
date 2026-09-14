#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Unit tests for scripts/comment_pr_artifacts.py."""

import importlib.util
import json
import unittest
from pathlib import Path
from unittest.mock import MagicMock, patch

SCRIPT = Path(__file__).resolve().parent / "comment_pr_artifacts.py"

_spec = importlib.util.spec_from_file_location("comment_pr_artifacts", SCRIPT)
cpa = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(cpa)


class TestCommentPrArtifacts(unittest.TestCase):
    def test_format_size(self):
        self.assertEqual(cpa.format_size(500), "500 B")
        self.assertEqual(cpa.format_size(1024), "1.0 KB")
        self.assertEqual(cpa.format_size(1536), "1.5 KB")
        self.assertEqual(cpa.format_size(1048576), "1.0 MB")
        self.assertEqual(cpa.format_size(58476838), "55.8 MB")
        self.assertEqual(cpa.format_size(1073741824), "1.00 GB")

    def test_generate_comment_body_all_artifacts(self):
        artifacts = [
            {"name": "uyuni-docs-html", "id": 101, "size_in_bytes": 50000000},
            {"name": "uyuni-docs-pdf-en", "id": 102, "size_in_bytes": 20000000},
            {"name": "mlm-docs-html", "id": 103, "size_in_bytes": 30000000},
            {"name": "mlm-docs-pdf-en", "id": 104, "size_in_bytes": 10000000},
        ]
        body = cpa.generate_comment_body(
            repo="uyuni-project/uyuni-docs",
            run_id="12345",
            commit_sha="abcdef1234567890",
            artifacts=artifacts,
        )

        self.assertIn(cpa.COMMENT_MARKER, body)
        self.assertIn("[`abcdef1`](https://github.com/uyuni-project/uyuni-docs/commit/abcdef1234567890)", body)
        self.assertIn("[#12345](https://github.com/uyuni-project/uyuni-docs/actions/runs/12345)", body)
        self.assertIn("### Uyuni Documentation", body)
        self.assertIn("https://github.com/uyuni-project/uyuni-docs/actions/runs/12345/artifacts/101", body)
        self.assertIn("https://github.com/uyuni-project/uyuni-docs/actions/runs/12345/artifacts/102", body)
        self.assertIn("### SUSE Multi-Linux Manager Documentation", body)
        self.assertIn("https://github.com/uyuni-project/uyuni-docs/actions/runs/12345/artifacts/103", body)
        self.assertIn("https://github.com/uyuni-project/uyuni-docs/actions/runs/12345/artifacts/104", body)

    def test_generate_comment_body_partial_and_extra(self):
        artifacts = [
            {"name": "uyuni-docs-html", "id": 201, "size_in_bytes": 1048576},
            {"name": "custom-bundle", "id": 202, "size_in_bytes": 2048},
        ]
        body = cpa.generate_comment_body(
            repo="my-org/my-repo",
            run_id="999",
            commit_sha=None,
            artifacts=artifacts,
        )

        self.assertIn(cpa.COMMENT_MARKER, body)
        self.assertIn("latest commit", body)
        self.assertIn("### Uyuni Documentation", body)
        self.assertNotIn("### SUSE Multi-Linux Manager Documentation", body)
        self.assertIn("### Additional Artifacts", body)
        self.assertIn("- 📦 [custom-bundle](https://github.com/my-org/my-repo/actions/runs/999/artifacts/202) (2.0 KB)", body)

    @patch.object(cpa, "run_command")
    def test_find_existing_comment_id_found(self, mock_run):
        mock_run.return_value = (
            json.dumps({
                "comments": [
                    {
                        "url": "https://github.com/foo/bar/pull/1#issuecomment-987654",
                        "body": f"{cpa.COMMENT_MARKER}\n## 📚 Documentation build artifacts",
                    }
                ]
            }),
            0,
            "",
        )
        comment_id = cpa.find_existing_comment_id("1", "foo/bar")
        self.assertEqual(comment_id, "987654")

    @patch.object(cpa, "run_command")
    def test_find_existing_comment_id_not_found(self, mock_run):
        mock_run.return_value = (
            json.dumps({
                "comments": [
                    {
                        "url": "https://github.com/foo/bar/pull/1#issuecomment-987654",
                        "body": "Looks good to me!",
                    }
                ]
            }),
            0,
            "",
        )
        comment_id = cpa.find_existing_comment_id("1", "foo/bar")
        self.assertIsNone(comment_id)

    @patch.object(cpa, "run_command")
    def test_is_pr_open(self, mock_run):
        mock_run.return_value = (json.dumps({"state": "OPEN"}), 0, "")
        self.assertTrue(cpa.is_pr_open("10", "foo/bar"))

        mock_run.return_value = (json.dumps({"state": "MERGED"}), 0, "")
        self.assertFalse(cpa.is_pr_open("10", "foo/bar"))

        mock_run.return_value = (json.dumps({"state": "CLOSED"}), 0, "")
        self.assertFalse(cpa.is_pr_open("10", "foo/bar"))

    @patch.object(cpa, "find_existing_comment_id")
    @patch.object(cpa, "run_command")
    def test_post_or_update_comment_update(self, mock_run, mock_find):
        mock_find.return_value = "55555"
        mock_run.return_value = ("", 0, "")

        success = cpa.post_or_update_comment("12", "foo/bar", "body text")
        self.assertTrue(success)
        mock_run.assert_called_once()
        cmd = mock_run.call_args[0][0]
        self.assertIn("repos/foo/bar/issues/comments/55555", cmd)
        self.assertIn("PATCH", cmd)

    @patch.object(cpa, "find_existing_comment_id")
    @patch.object(cpa, "run_command")
    def test_post_or_update_comment_create(self, mock_run, mock_find):
        mock_find.return_value = None
        mock_run.return_value = ("", 0, "")

        success = cpa.post_or_update_comment("12", "foo/bar", "body text")
        self.assertTrue(success)
        mock_run.assert_called_once()
        cmd = mock_run.call_args[0][0]
        self.assertIn("repos/foo/bar/issues/12/comments", cmd)
        self.assertIn("POST", cmd)

    @patch.object(cpa, "find_existing_comment_id")
    @patch.object(cpa, "run_command")
    def test_post_or_update_comment_fork_permission_error(self, mock_run, mock_find):
        mock_find.return_value = None
        mock_run.return_value = ("", 1, "HTTP 403: Resource not accessible by integration")

        # Must return True (graceful exit) so CI doesn't fail on fork PRs
        success = cpa.post_or_update_comment("12", "foo/bar", "body text")
        self.assertTrue(success)


if __name__ == "__main__":
    unittest.main()
