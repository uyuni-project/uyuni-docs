# Documentation Release Checklist

Use this issue template for documentation releases.

## Packaging Day:

- [ ] Ensure all relevant PRs are merged (and backported where required)
- [ ] Cut a new branch from master using syntax ``manager-x.y-betaz``
- [ ] Build both SUMA and Uyuni docs from release branch and visually check output
- [ ] Package documentation and push SR to OBS: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-obs
- [ ] Notify Release Manager of SR
- [ ] Release Manager accepts package


## Release Day:

- [ ] Build both SUMA and Uyuni docs from release branch and visually check output
- [ ] Publish to documentation.suse.com: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-enterprise-endpoints
- [ ] Publish to opensource.suse.com: https://github.com/uyuni-project/uyuni-docs/wiki/publishing-to-master-branches-on-github-pages
- [ ] When endpoints are live, visually check output
