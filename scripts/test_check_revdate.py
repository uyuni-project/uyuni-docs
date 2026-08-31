#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Tests for check_revdate.py."""

import importlib.util
import os
import subprocess
import tempfile
import unittest
from datetime import date
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent / "check_revdate.py"

_spec = importlib.util.spec_from_file_location("check_revdate", SCRIPT)
check_revdate = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(check_revdate)


PAGE = "en/modules/administration/pages/example.adoc"

GIT_IDENTITY = [
    "-c", "user.name=Test",
    "-c", "user.email=test@example.invalid",
    "-c", "commit.gpgsign=false",
]


def git_env(author_date=None, committer_date=None):
    """Pin identity, config and clock."""
    env = os.environ.copy()
    env["GIT_CONFIG_GLOBAL"] = os.devnull
    env["GIT_CONFIG_SYSTEM"] = os.devnull
    if author_date is not None:
        env["GIT_AUTHOR_DATE"] = f"{author_date.isoformat()}T12:00:00 +0000"
    if committer_date is not None:
        env["GIT_COMMITTER_DATE"] = f"{committer_date.isoformat()}T12:00:00 +0000"
    return env


def page_body(revdate=None, page_revdate="{revdate}", title="Example"):
    lines = [f"= {title}"]
    if revdate is not None:
        lines.append(f":revdate: {revdate}")
        if page_revdate is not None:
            lines.append(f":page-revdate: {page_revdate}")
    lines += ["", "Some content.", ""]
    return "\n".join(lines)


class RepoFixture:
    """A throwaway git repo with fixed dates."""

    def __init__(self, root):
        self.root = Path(root)
        self._git("init", "-q", "-b", "master")

    def _git(self, *args, when=None, env=None):
        return subprocess.run(
            ["git"] + GIT_IDENTITY + list(args),
            cwd=str(self.root),
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            universal_newlines=True,
            env=env if env is not None else git_env(when, when),
        ).stdout

    def write(self, rel_path, content):
        path = self.root / rel_path
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def commit(self, when, message="change"):
        self._git("add", "-A")
        self._git("commit", "-q", "-m", message, when=when)

    def check(self, rel_path, grace_days=7, today=None):
        return check_revdate.check_file(
            rel_path,
            self.root,
            grace_days,
            today or date(2026, 1, 1),
        )


class CheckFileTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.repo = RepoFixture(self._tmp.name)
        self.addCleanup(self._tmp.cleanup)

    def commit_page(self, body, when):
        self.repo.write(PAGE, body)
        self.repo.commit(when)

    def test_valid_page_passes(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body("2026-01-01"), day)
        self.assertEqual(self.repo.check(PAGE, today=day), [])

    def test_missing_revdate_is_an_error(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body(None), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertEqual(len(errors), 1)
        self.assertIn(":revdate: attribute is absent", errors[0][1])

    def test_wrong_format_is_an_error(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body("20-03-2025"), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertEqual(len(errors), 1)
        self.assertIn("YYYY-MM-DD", errors[0][1])

    def test_impossible_date_is_an_error(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body("2025-02-30"), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertEqual(len(errors), 1)
        self.assertIn("not a correct calendar date", errors[0][1])

    def test_future_revdate_is_an_error(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body("2035-01-01"), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertTrue(any("in the future" in message for _, message in errors))

    def test_tomorrow_is_allowed_for_authors_ahead_of_utc(self):
        """An author east of UTC writes tomorrow."""
        day = date(2026, 1, 1)
        self.commit_page(page_body("2026-01-02"), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertEqual([m for _, m in errors if "in the future" in m], [])

    def test_two_days_ahead_is_still_an_error(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body("2026-01-03"), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertTrue(any("in the future" in message for _, message in errors))

    def test_missing_page_revdate_is_an_error(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body("2026-01-01", page_revdate=None), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertEqual(len(errors), 1)
        self.assertIn("page-revdate", errors[0][1])

    def test_page_revdate_must_be_the_attribute_reference(self):
        day = date(2026, 1, 1)
        self.commit_page(page_body("2026-01-01", page_revdate="2026-01-01"), day)
        errors = self.repo.check(PAGE, today=day)
        self.assertEqual(len(errors), 1)
        self.assertIn("page-revdate must be", errors[0][1])

    def test_revdate_within_grace_period_passes(self):
        commit_day = date(2026, 1, 8)
        self.commit_page(page_body("2026-01-01"), commit_day)
        self.assertEqual(
            self.repo.check(PAGE, grace_days=7, today=commit_day), []
        )

    def test_revdate_past_grace_period_is_an_error(self):
        commit_day = date(2026, 1, 9)
        self.commit_page(page_body("2026-01-01"), commit_day)
        errors = self.repo.check(PAGE, grace_days=7, today=commit_day)
        self.assertTrue(any("too old" in message for _, message in errors))

    def test_old_page_untouched_since_its_revdate_passes(self):
        """Only a change needs a new revdate."""
        day = date(2020, 5, 10)
        self.commit_page(page_body("2020-05-10"), day)
        self.assertEqual(self.repo.check(PAGE, today=date(2026, 1, 1)), [])

    def test_rebase_does_not_make_a_page_look_stale(self):
        """A rebase moves the committer date only."""
        self.repo.write(PAGE, page_body("2026-01-01"))
        self.repo._git("add", "-A")
        self.repo._git(
            "commit", "-q", "-m", "authored long ago",
            env=git_env(date(2026, 1, 1), date(2026, 3, 2)),
        )
        self.assertEqual(
            self.repo.check(PAGE, grace_days=7, today=date(2026, 3, 2)), []
        )

    def test_include_fragment_under_pages_is_an_error(self):
        """Antora publishes it as an orphan page."""
        day = date(2026, 1, 1)
        fragment = "==== Image Inspection\n\nSome included content.\n"
        self.commit_page(fragment, day)
        errors = self.repo.check(PAGE, today=day)
        self.assertTrue(any("no document title" in m for _, m in errors))

    def test_a_title_with_no_text_does_not_count_as_a_document_title(self):
        day = date(2026, 1, 1)
        self.commit_page("=\n\nNot a real title.\n", day)
        errors = self.repo.check(PAGE, today=day)
        self.assertTrue(any("no document title" in m for _, m in errors))

    def test_title_after_an_anchor_and_blank_line_is_found(self):
        """workflow-liberate-rhel-with-secureboot.adoc has this shape."""
        day = date(2026, 1, 1)
        body = (
            "[[some-anchor]]\n\n= Real Title\n:revdate: 2026-01-01\n"
            ":page-revdate: {revdate}\n\nContent.\n"
        )
        self.commit_page(body, day)
        self.assertEqual(self.repo.check(PAGE, today=day), [])

    def test_ifeval_preamble_before_the_title_is_fine(self):
        """proxy-conversion-from-client-*.adoc opens with ifeval."""
        day = date(2026, 1, 1)
        body = (
            "ifeval::[{uyuni-content} == true]\n\n:noindex:\nendif::[]\n\n"
            "[[anchor]]\n= Real Title\n:revdate: 2026-01-01\n"
            ":page-revdate: {revdate}\n\nContent.\n"
        )
        self.commit_page(body, day)
        self.assertEqual(self.repo.check(PAGE, today=day), [])

    def test_multiple_problems_are_all_reported(self):
        commit_day = date(2026, 6, 1)
        self.commit_page(page_body("2026-01-01", page_revdate=None), commit_day)
        errors = self.repo.check(PAGE, grace_days=7, today=commit_day)
        self.assertEqual(len(errors), 2)


class ScopeTests(unittest.TestCase):
    def test_pages_are_in_scope(self):
        self.assertTrue(
            check_revdate.in_scope("en/modules/administration/pages/support.adoc")
        )

    def test_nested_pages_are_in_scope(self):
        self.assertTrue(
            check_revdate.in_scope(
                "en/modules/installation-and-upgrade/pages/container-deployment/"
                "mlm/proxy-conversion-from-client-mlm.adoc"
            )
        )

    def test_partials_are_out_of_scope(self):
        self.assertFalse(
            check_revdate.in_scope(
                "en/modules/client-configuration/partials/trust_gpg.adoc"
            )
        )

    def test_nav_files_are_out_of_scope(self):
        self.assertFalse(check_revdate.in_scope("en/modules/ROOT/nav.adoc"))
        self.assertFalse(
            check_revdate.in_scope("en/modules/retail/nav-retail-guide.adoc")
        )

    def test_attributes_files_are_out_of_scope(self):
        self.assertFalse(check_revdate.in_scope("en/modules/legal/_attributes.adoc"))
        self.assertFalse(
            check_revdate.in_scope("branding/locale/attributes-de.adoc")
        )

    def test_readme_is_out_of_scope(self):
        self.assertFalse(check_revdate.in_scope("README.adoc"))

    def test_translations_are_out_of_scope(self):
        self.assertFalse(
            check_revdate.in_scope("translations/ja/modules/ROOT/pages/index.adoc")
        )

    def test_non_adoc_is_out_of_scope(self):
        self.assertFalse(
            check_revdate.in_scope("en/modules/ROOT/pages/assets/diagram.png")
        )


class BaseRefTests(unittest.TestCase):
    """GITHUB_BASE_REF is empty outside a pull request."""

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        self.addCleanup(self._tmp.cleanup)

    def test_empty_env_var_falls_back_to_master(self):
        import os

        previous = os.environ.get("GITHUB_BASE_REF")
        os.environ["GITHUB_BASE_REF"] = ""
        try:
            self.assertEqual(
                check_revdate.resolve_base_ref(None, self.root), "master"
            )
        finally:
            if previous is None:
                os.environ.pop("GITHUB_BASE_REF", None)
            else:
                os.environ["GITHUB_BASE_REF"] = previous

    def test_explicit_base_ref_wins(self):
        self.assertEqual(
            check_revdate.resolve_base_ref("origin/manager-5.2", self.root),
            "origin/manager-5.2",
        )


class ChangedFileTests(unittest.TestCase):
    """Git reports a moved page as renamed."""

    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.repo = RepoFixture(self._tmp.name)
        self.addCleanup(self._tmp.cleanup)

    def test_renamed_page_is_discovered(self):
        day = date(2026, 1, 1)
        self.repo.write(PAGE, page_body("2026-01-01"))
        self.repo.commit(day)
        self.repo._git("branch", "base")

        moved = "en/modules/administration/pages/renamed.adoc"
        self.repo._git("mv", PAGE, moved)
        self.repo.commit(day, message="rename")

        changed = check_revdate.get_changed_files("base", self.repo.root)
        self.assertIn(moved, changed)


if __name__ == "__main__":
    unittest.main(verbosity=2)
