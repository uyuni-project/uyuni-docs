# Documentation Release Checklist

Use this issue template for documentation releases.

## Before Packaging Day

- [ ] Check for previous SLES SP versions in the text, and update where necessary.
- [ ] Review the content sensitive help in the UI, and ensure all links are up to date.
- [ ] Check all outstanding pull requests, and ensure everything relevant is merged (and backported where required).
Check with the docs squad coordinator for confirmation.


## Packaging Day:

- [ ] Update entities to the current versions.
- [ ] Cut a new branch from master using syntax `manager-x.y-betaz`.
- [ ] Locally build both SUMA and Uyuni docs from the release branch and visually check output.
- [ ] Package documentation and push SR to OBS: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-obs
- [ ] Notify Release Manager of SR.
- [ ] Release Manager accepts package.


## Release Day:

- [ ] Build both SUMA and Uyuni docs from release branch and visually check output.
- [ ] Publish to documentation.suse.com: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-enterprise-endpoints
- [ ] Publish to opensource.suse.com: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-master-branches-on-github-pages
- [ ] When endpoints are live, visually check output.
