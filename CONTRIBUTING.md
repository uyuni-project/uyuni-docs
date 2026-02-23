# Contributing

## First Contribution

### Configure Git Commit Signing

Commit signing with a GPG or SSH key is required. Verified commits ensure authenticity. See the [GitHub documentation](https://docs.github.com/en/authentication/managing-commit-signature-verification/about-commit-signature-verification) for details.

### Contributing Using a Fork

* Ensure you have a GitHub account and are signed in.
* Fork the repository: [https://github.com/uyuni-project/uyuni-docs.git](https://github.com/uyuni-project/uyuni-docs.git)
* Clone your fork:

```bash
git clone https://github.com/<username>/uyuni-docs.git
```

* Switch to the master branch:

```bash
cd uyuni-docs
git checkout master
```

* Add the upstream repository:

```bash
git remote add upstream https://github.com/uyuni-project/uyuni-docs.git
```

* Fetch and merge changes from upstream regularly.
* Create a feature branch for your work:

```bash
git checkout -b update-readme-username
```

### Contributing With Write Access

If you have direct write access, clone the repository, check out the master branch, and create feature branches as needed.

## Committing Changes and Creating a Pull Request

* Make and verify your changes locally.
* Stage and commit files:

```bash
git add .
git commit -m "Commit message"
```

* Push your branch:

```bash
git push --set-upstream origin <branchname>
```

* Create a Pull Request on GitHub. Provide a clear title and description, select reviewers, and open a Draft PR if work is in progress.

NOTE: Technical changes require a review from a subject matter expert (SME).
All changes require documentation team review.

## Review Standards

* Mark incomplete work with `[WIP]` in the PR title.
* Do not merge another author’s PR without explicit permission.
* Approvals required:
  * One SME for technical changes.
  * One documentation team member for all changes.

## Second Contribution

Keep your fork or local copy synchronized to avoid conflicts. Always update `master` before new work.

### Using a Fork

* Check out your fork’s `master` branch.
* Fetch from upstream and merge into `master`.
* Continue work on existing feature branches or create new ones.

### With Write Access

* Check out the `master` branch.
* Fetch all branches and update:

```bash
git fetch --all
git pull -ff
```

* Create new branches for new work.
* Commit early, push often, and use Draft PRs.

## Changelog Entries

Update `CHANGELOG.md` with your changes. Add new entries at the top:

```md
- Updated Foo chapter in Installation and Upgrade Guide
- Documented Bar feature in Administration Guide
- Fixed error in Bat section of Upgrade Guide (bsc#1234567)
```

[Guidelines](https://en.opensuse.org/openSUSE:Creating_a_changes_file_(RPM))
