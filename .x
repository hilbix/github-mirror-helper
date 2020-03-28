#!/bin/bash

# always work in the current directory
# XXX TODO XXX add some config to more easily work in a working directory?
cd -- "$(dirname -- "$0")" || exit
. bashy/boilerplate.inc '' || exit

GITHUB="$(git config --get github.user)" || OOPS git config --add github.user YOURUSER

FROM="https://github.com/$GITHUB/"
DEST="githubmirror:$GITHUB/"
# How the Wiki is called (space separated list)
EXTS=wiki

# common settings
TODO=TODO
FAIL=FAIL
WORK=git
SKIP=SKIP

# Start the mirroring
# Create runtime directories (will be removed again if empty)

[ -d "$TODO/fail" ] && mvatom -id "$TODO" "$TODO/fail/"*
mkdir -p "$TODO/clone" "$TODO/pull" "$TODO/push" "$TODO/wiki" "$FAIL"

# Process all if called as: ./.x -
[ .- = ".$*" ] && set -- "$WORK/"*.git

# Run the given repos.  Note: If repo does not exist it is learned
for a
do
	b="${a%/}"
	b="${b##*/}"
	b="${b%.git}"
	for c in $EXTS
	do
		b="${b%".$c"}"
	done
	case "$b" in
	(''|*[^a-zA-Z0-9._-]*)	printf 'NO: %q\n' "$a";;
	(*)			touch "$TODO/clone/$b";;
	esac
done

log()
{
{
printf 'LOG:'
printf ' %q' "$@"
printf '\n'
} >&2
}

x()
{
{
printf '[['
printf ' %q' "$@"
printf ']]\n'
} >&2
"$@"
}

GIT()
{
GIT_CONFIG_NOSYSTEM=true HOME=. XDG_CONFIG_HOME=. x git "$@"
}

clone()	{ log init "$1"; GIT clone --mirror "$FROM$1.git"; }
pull()	{ log pull "$1"; GIT remote update -p; }
push()	{ log push "$1"; GIT push --mirror "$DEST$1.git"; }

# Process EXTS variable (usually "wiki"),
# commonly this processes .wiki.git
# however there is more supported if it exists.
#
# Note that "repo.wiki.git" is not a good choice by GitHub etc.
# as you cannot create a repo called some.wiki.git yourself.
# You have to create some.git which then includes some.wiki.git.
#
# WTF, why?  Why is the Wiki a special repo?
# Just create some.git.
# If you create a WIKI for it, it goes into some.wiki.git
# But some.wiki.git then is just a normal repo,
# which can have a wiki,
# which goes into some.wiki.wiki.git
#
# Where is the problem?
#
# NOTE:
#
# If cloning some EXTS fails, this is not automatically retried!
# to allow a retry: rm -rf FAIL
wiki()
{
ok=:
for c in $EXTS
do
	b="$1"
	for d in $EXTS
	do
		# Can wikis have wikis?
		# (Not on GitHub)
		b="${b%".$d"}"
	done
	b="$b.$c"

	if	[ -e "$WORK/$b.git" ]
	then
		touch "$TODO/pull/$b"
	else
		[ -e "$FAIL/$b" ] || touch "$TODO/clone/$b"
	fi ||
	ok=false
done
$ok
}

try()
{
[ -f "$1" ] || return
( cd "$2" && "${@:3}" ) || { mvatom -appd "$TODO/fail/$3" "$1"; return 1; }
}

# Process cloning a new repository
# If already cloned, do a pull and try the wiki ($EXTS)
# Next step is pull
#
# If initial cloning fails, it is not automatically retried.
# To retry you can give it a second time on commandline.
# To retry a wiki ($EXTS), see above.
for a in "$TODO/clone/"*
do
	[ -f "$a" ] || continue

	b="${a##*/}"
	[ -d "$WORK/$b.git" ] && mv -ft "$TODO/pull" "$a" && touch "$TODO/wiki/$b" && continue

	try "$a" "$WORK" clone "$b" &&

	touch "$TODO/push/$b" &&

	case "$b" in
	(*.*)	;;
	(*)	touch "$TODO/wiki/$b";;
	esac &&

	rm -f "$a" ||

	touch "$FAIL/$b"
done

# Semiautomatically add the WIKIs.
# Note that this processes all the $EXTS
#
# This is retried only once.  See comment above.
#
# Note that you need to rerun this script to clone the wikis, too.
# This is on purpose.  First, concentrate on the main thing,
# then on all others.
for a in "$TODO/wiki/"*
do
	try "$a" . wiki "${a##*/}" &&
	rm -f "$a"
done

# Pull in new data of cloned repos
# Next step is pull
for a in "$TODO/pull/"*
do
	b="${a##*/}"

	[ -d "$WORK/$b.git" ] || continue
	[ -f "$SKIP/$b.git" ] && continue

	try "$a" "$WORK/$b.git" pull "$b" &&
	touch "$TODO/push/$b" &&
	rm -f "$a"
done

# Push the pulled data
for a in "$TODO/push/"*
do
	b="${a##*/}"
	[ -f "$SKIP/$b.git" ] && continue

	try "$a" "$WORK/$b.git" push "$b" &&
	rm -f "$a"
done

# Cleanup FAILed clones due to $EXTS
if	[ -d "$TODO/fail" ]
then
	for a in $EXTS
	do
		for b in "$TODO/fail/clone/"*".$a"
		do
			[ -f "$b" ] && [ -f "$FAIL/${b##*/}" ] && rm -f "$b"
		done
	done
	rmdir "$TODO/fail/"*
fi

# Try to cleanup everything else
# This ususally means succes, ignoring failed Wikis ($EXTS)
rmdir "$TODO/"* "$TODO" && exit

# Remember to create a missing destination
if	[ -d "$TODO/fail/push" ]
then
	printf '\nmissing/unreachable repositories on %q:\n' "$DEST"
	for a in "$TODO/fail/push/"*
	do
		printf '\t%q\n' "${a##*/}"
	done
	printf '\n'
	printf 'Hint: If you need to hack the remote name, do:\n'
	printf 'cd %q && while read -p "githubreponame mirrorreponame: " repo dest; do ( repo="${repo%%/}"; repo="${repo%%.git}"; repo="${repo%%%%*/}"; cd %q/"$repo.git" && git config --local "url.%q${dest##*/}.insteadOf" %q"$repo".git ); done\n' "$PWD" "$WORK" "$DEST" "$DEST"
	printf 'To list the already known mapping, do: make -C %q show\n' "$PWD"
fi

exit 1

