---
name: Documentation Release Checklist - Uyuni
about: Use this issue template for documentation releases.
title: Documentation Release Checklist - Uyuni YYYY.MM
labels: docs backlog
assignees: Loquacity, jcayouette

---

## Before Packaging Day

- [ ] Check for previous Uyuni versions in the text, and update where necessary.
- [ ] Check all outstanding pull requests, and ensure everything relevant is merged (and backported where required).
Check with the docs squad coordinator for confirmation.


## Packaging Day:

- [ ] Update entities to the current versions.
- [ ] Cut a new branch from master using syntax `uyuni-YYYY-MM-pages` based on the gh-pages branch.
- [ ] Locally build docs from the release branch and visually check output.
- [ ] Package documentation and push SR to OBS: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-obs
- [ ] Notify Release Manager of SR.
- [ ] Release Manager accepts package.


## Release Day:

- [ ] Build docs from release branch and visually check output.
- [ ] Publish Uyuni to gh-pages: https://github.com/uyuni-project/uyuni-docs/tree/gh-pages. Add Release Manager as the assignee, and use a label with current Uyuni version.
- [ ] When endpoints are live, visually check output.
