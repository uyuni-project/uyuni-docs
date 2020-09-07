# Documentation Release Checklist

Use this issue template for documentation releases.

## Before Packaging Day

- [ ] Check for previous SLES SP versions in the text, and update where necessary.
- [ ] Review the content sensitive help in the UI, and ensure all links are up to date.
- [ ] Check all outstanding pull requests, and ensure everything relevant is merged (and backported where required).
Check with the docs squad coordinator for confirmation.


## Packaging Day:

- [ ] Update entities to the current versions.
- [ ] For SUMA, cut a new branch from master using syntax `manager-x.y-betaz`.
- [ ] For Uyuni, cut a new branch from master using syntax `uyuni-YYYY-MM-pages` based on the gh-pages branch.
- [ ] Locally build both SUMA and Uyuni docs from the release branch and visually check output.
- [ ] Package documentation and push SR to OBS: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-obs
- [ ] Notify Release Manager of SR.
- [ ] Release Manager accepts package.


## Release Day:

- [ ] Build both SUMA and Uyuni docs from release branch and visually check output.
- [ ] Publish to documentation.suse.com: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-enterprise-endpoints
- [ ] Publish Uyuni to gh-pages: https://github.com/uyuni-project/uyuni-docs/tree/gh-pages. Add Release Manager as the assignee, and use a label with current Uyuni version.
- [ ] When endpoints are live, visually check output.
