#!/bin/bash

FROM='https://github.com/hilbix/'
DEST='githubmirror:hilbix/'
TODO=TODO
FAIL=FAIL
EXTS=wiki

cd "$(dirname -- "$0")" || exit

[ -d "$TODO/fail" ] && mvatom -id "$TODO" "$TODO/fail/"*
mkdir -p "$TODO/clone" "$TODO/pull" "$TODO/push" "$TODO/wiki" "$FAIL"

[ .- = ".$*" ] && set -- 'git/'*.git

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
	(''|*[^a-zA-Z0-9.-]*)	printf 'NO: %q\n' "$a";;
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

wiki()
{
ok=:
for c in $EXTS
do
	b="$1"
	for d in $EXTS
	do
		# Can wikis have wikis?
		b="${b%".$d"}"
	done
	b="$b.$c"

	if	[ -e "git/$b.git" ]
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

for a in "$TODO/clone/"*
do
	[ -f "$a" ] || continue

	b="${a##*/}"
	[ -d "git/$b.git" ] && mv -ft "$TODO/pull" "$a" && touch "$TODO/wiki/$b" && continue

	try "$a" git clone "$b" &&

	touch "$TODO/push/$b" &&

	case "$b" in
	(*.*)	;;
	(*)	touch "$TODO/wiki/$b";;
	esac &&

	rm -f "$a" ||

	touch "$FAIL/$b"
done

for a in "$TODO/wiki/"*
do
	try "$a" . wiki "${a##*/}" &&
	rm -f "$a"
done

for a in "$TODO/pull/"*
do
	b="${a##*/}"

	[ -d "git/$b.git" ] || continue

	try "$a" "git/$b.git" pull "$b" &&
	touch "$TODO/push/$b" &&
	rm -f "$a"
done

for a in "$TODO/push/"*
do
	b="${a##*/}"

	try "$a" "git/$b.git" push "$b" &&
	rm -f "$a"
done

# Cleanup FAILs if in $EXTS
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

rmdir "$TODO/"* "$TODO" && exit

if	[ -d "$TODO/fail/push" ]
then
	printf '\nmissing repositories on %q:\n' "$DEST"
	for a in "$TODO/fail/push/"*
	do
		printf '\t%q\n' "${a##*/}"
	done
	printf '\n'
fi

exit 1

