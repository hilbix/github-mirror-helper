> This is done in a hurry.  Do not expect clean production-like code.

# Mirror your GitHub

Mirrors all public GitHub repos of one account to some other `git` (named `gitmirror`).

## Usage

	git clone --recursive https://github.com/hilbix/github-mirror-helper.git
	cd github-mirror-helper
	git config --add github.user hilbix
	./.update
	./.update
	./.x
	./.x

You will see some failures.  If the failure is due to the source, try

	touch SKIP/repo.git

If the failure is due to the destination, hack the remote names using
the while loop which is printed by `./.x`.

For example my GitLab does not allow dots or uppercase,
so it looks like following:

	RePo_name.on_GitHub https://mygitlab.localhost.example.com/hilbix/repo_name-on_gitlab.git

The left side is printed by `./.x` while the right side is copied from the clone
URL of GitLab.  This works for Wikis, too.

