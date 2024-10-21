# Some hints

Consider adding an entry to the `CHANGELOG.md` file in the toplevel directory.
Cosmetic changes such as fixing typos do not need log entries (nevertheless it is important to fix typos, etc.)!
In the `manager-4.3`, the hidden `.changelog` file with a leading dot is still in use.

Add Description, Target branches, and related Links below the following section titles.

In the Description, just enter a summary of why you created this PR (and, if available, add any relevant diagram).

# Description

Short summary of why you created this PR (if you added documentation, please add any relevant diagram).

# Target branches

* Which product version this PR applies to (Uyuni, SUMA 4.3, SUMA MU X.Y.Z, or SUMA development version).  This information can be helpful if `ifeval` statements are needed to publish it for certain products only.
* Does this PR need to be backported? If yes, create an issue for tracking it and add the link to this PR.
* Whenever possible, cross-reference each backport PR here, so that all backports can be easily accessed from the description.

Backport targets (edit as needed):

- master
- 5.0
- 4.3

# Links
- This PR tracks issue #<insert spacewalk issue, if any>
- Related development PR #<insert PR link, if any>
