#

.PHONY:	love
love:	all

.PHONY:	all
all:
	./.x -

.PHONY:	show
show:
	for a in git/*.git; do ( cd "$$a" && git config --local --get-regex ^url 2>/dev/null | cat; ); done

