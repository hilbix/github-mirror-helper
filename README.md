> This is done in a hurry.  Do not expect clean production-like code.

# Mirror your GitHub

Mirrors all public GitHub repos of one account to some other `git` (named `gitmirror`).


## Usage

	cd
	git clone https://github.com/hilbix/json2sh.git
	cd json2sh
	make
	sudo make install

	cd
	git clone --recursive https://github.com/hilbix/md5chk.git
	cd md5chk
	make
	sudo make install

	cd
	git clone --recursive https://github.com/hilbix/github-mirror-helper.git
	cd github-mirror-helper

	git config --add github.user $GITHUBNAMETOMIRROR


## Run

Data is written into `git/` and some other directories directly where this
repo is.  A typical update run looks like (yes, both doubled) this:

	make -C github-mirror-helper update
	make -C github-mirror-helper update
	make -C github-mirror-helper
	make -C github-mirror-helper

If you see some failures fix them and then rerun `./.x`.

If the failure is due to missing destination, create the destination.
Sorry, this must be done manually.  Only all the GitHub repos are
detected with this script.

If the failure is due to the source, try

	touch SKIP/repo.git

If the failure is due to the destination, hack the remote names using
the while loop which is printed by `./.x`.

For example my GitLab does not allow dots or uppercase,
so it looks like following:

	RePo_name.on_GitHub https://mygitlab.localhost.example.com/hilbix/repo_name-on_gitlab.git

The left side is printed by `./.x` while the right side is copied from the clone
URL of GitLab.  This works for Wikis, too.


## Notes

You might hit GitHub rate limiting if you try to scan more than
30 accounts or more than 3000 repositories within less than 1 hour.
It might be even less if you do other GitHub API calls (you have 60 API requests per
hour!  `./.update` uses at least one plus another one for each 100 repos).

> Note: For each account you need a separate clone of this repo.

In that case, interrupt `./.update` **manually** and wait an hour before restarting it!
**Currenyly rate limiting is probably not recognized,
so if you use this script too excessively,
your IP might get banned on GitHub!**

> I never hit the rate limit yet, so I do not know what exactly happens.
> Perhaps you see some `OOPS` because `curl` fails, but I am not sure.

In normal circumstances there should not be any problem to interrupt `./.update`
and restart it, as `./.update` is able to use conditional requests,
so rate-limiting only applies to repo changes or new repos.

AFAICS there is no rate limit on `git clone`, so `./.x` probably has no limits.


## FAQ

License?

- This is free as in free beer, free speech and free baby.
- Do not add a Copyright.

Why is there no automated API call to create the destination?

- The destination can be anything.
- I deactivated external API calls on my GitLab for security reason, so I was not able to use it.
- It can be added in the last few lines of `./.x`

Can the path on the remote differ from the GitHub account name?

- Not yet implemented.  At my side I mirror from github.com/hilbix to the same path on GitLab.
- Perhaps you can use some general `git` rewriting (`git config url.xxx.insteadOf yyy`) somehow,
  but I did not test it.

`make love`?

- Yeah, baby!  Love is all you need!
- Because `make all` seems to be a bit blasphemic and `make war` far too violent.
- So that's the way, I like it!

