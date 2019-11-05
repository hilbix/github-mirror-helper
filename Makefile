#

.PHONY:	love
love:	all

.PHONY:	all
all:
	if [ -d TODO ]; then ./.x; else ./.x -; fi

.PHONY:	show
show:
	for a in git/*.git; do ( cd "$$a" && git config --local --get-regex ^url 2>/dev/null | cat; ); done

