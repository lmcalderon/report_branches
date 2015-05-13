#!/bin/bash

#export NOW=$(date +%s)
#export MAX_AGE=$((30*24*60*60))

printf '\n\n%s\n' " --- Pruned Branches --- "
git remote prune origin

printf '\n\n%s\n' " --- Dangling Local Branches --- "
git branch -l | sed 's/* master//' > gitlocal.txt
git branch -r | sed 's/origin\///' > gitremote.txt
grep -Fxv -f gitremote.txt gitlocal.txt
printf '%s\n\n' " --- "

git show-ref |
grep refs/remotes/origin/ | # Only process branches on origin.
grep -v refs/remotes/origin/private/ | # Skip private branches.
egrep -v 'refs/remotes/origin/(master)$' | # Skip master and develop.
while read REVISION REFERENCE; do
	# Skip young branches.
	#[ $(($NOW - $(git log -n 1 --format=%ct $REFERENCE))) -gt $MAX_AGE ] || continue

  # Skip brances that are not from us
  author=`git log -n 1 --format='%cE' $REFERENCE`
  result=`git log -n 1 --format='%cE' $REFERENCE | egrep -v '^((dcairol|david|dchaves|lserrano|mzumbado|alopez|jmontero)@cecropiasolutions.com)|((mauricio|lucia|jdchaves|jessica|jzuniga|roberto|gabriel|mjmontero|bruno)@dino-it.com)|((cec_maria|mauricio|cec_sergio|cec_sebastian)@spiceworks.com)$'`
  [ "$author" == "$result" ] && continue

	# Record whether or not the branch is fully merged into the master branch.
	MERGED='-'
	[ $(git merge-base origin/master $REVISION) = $REVISION ] && MERGED='M'

	# Report on old branches.
	printf '%s %-80s %s\n' "$MERGED" ${REFERENCE/#refs\/remotes\/origin\//} "$(git log -n 1 --format='%cN <%cE>' $REFERENCE)"
done