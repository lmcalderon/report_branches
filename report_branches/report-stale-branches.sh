#!/bin/bash

#printf '\n\n%s\n' " --- Branches --- "
#branches=$(git branch -r | egrep 'origin/(hotfix|release|target)')
#printf "${branches}\n"

BRAN=()              && BRANCHES=()
BRAN+=('R/7_4/P   ') && BRANCHES+=('target/7_4_patch')
BRAN+=('R/7_5     ') && BRANCHES+=('target/7_5_FIXIT')
BRAN+=('R/7_5/B2  ') && BRANCHES+=('target/7_5_beta_2')
BRAN+=('R/7_5/RC  ') && BRANCHES+=('target/7_5_rc')
BRAN+=('R/7_5/RC  ') && BRANCHES+=('target/7_6')


BRAN+=('R/7_4/P')    && BRANCHES+=('release/7_4_patch')
BRAN+=('R/7_4/PJSN') && BRANCHES+=('release/7_4_patch_june_sso-nate')
BRAN+=('R/A_B/A   ') && BRANCHES+=('release/ab_test_a')
BRAN+=('R/A_B/W_Un') && BRANCHES+=('release/ab_test_a_wo_unicorns')
BRAN+=('R/beta    ') && BRANCHES+=('release/beta')
BRAN+=('R/beta_a  ') && BRANCHES+=('release/beta_a')
BRAN+=('R/beta_2  ') && BRANCHES+=('release/7_5_beta_2')

BRAN+=('M         ') && BRANCHES+=('master')
total=${#BRANCHES[*]}

# e.g. constructing branches_string, pray it does not contain %s
separator="|"
branches_string="$( printf "${separator}%s" "${BRANCHES[@]}" )"
branches_string="${branches_string:${#separator}}" # remove leading separator
branches_string="^refs/remotes/origin/(${branches_string})$"

DINO_EMPLOYEE=()
DINO_EMPLOYEE+=('lucia')
DINO_EMPLOYEE+=('andres')
DINO_EMPLOYEE+=('manuel')
DINO_EMPLOYEE+=('jdchaves')
DINO_EMPLOYEE+=('anel')
DINO_EMPLOYEE+=('mauricio')
DINO_EMPLOYEE+=('jessica')
DINO_EMPLOYEE+=('jzuniga')
DINO_EMPLOYEE+=('denia')
DINO_EMPLOYEE+=('roberto')
DINO_EMPLOYEE+=('acorrales')
DINO_EMPLOYEE+=('gabriel')
DINO_EMPLOYEE+=('bruno')
DINO_EMPLOYEE+=('mjmontero')
DINO_EMPLOYEE+=('klinsmann')
DINO_EMPLOYEE+=('carlos')
DINO_EMPLOYEE+=('eduardo')

separator="|"
employees_string="$( printf "${separator}%s" "${DINO_EMPLOYEE[@]}" )"
employees_string="${employees_string:${#separator}}" # remove leading separator
employees_string="^(${employees_string})@dino-it.com$"

NOW=$(date +%s)
MAX_AGE=$((30*24*60*60))

printf '\n\n%s\n' " --- Pruned Branches --- "
git fetch
git remote prune origin

printf '\n\n%s\n' " --- Dangling Local Branches --- "
git branch -l | sed 's/* master//' > gitlocal.txt
git branch -r | sed 's/origin\///' > gitremote.txt
grep -Fxv -f gitremote.txt gitlocal.txt

printf '+++++++++++++\n\n'
git_local=$(git branch -l | sed 's/* master//')
git_remote=$(git branch -r | sed 's/origin\///')
grep -Fxv -f ${git_remote} ${git_local}
printf '%s\n\n' " --- "

git show-ref |
grep refs/remotes/origin | # Only process branches on origin.
grep -v refs/remotes/origin/private/ | # Skip private branches.
grep -v refs/remotes/origin/target/ | # Skip target branches.
grep -v refs/remotes/origin/hotfix/ | # Skip hotfix branches.
grep -v refs/remotes/origin/release/ | # Skip release branches.
egrep -v "refs/remotes/origin/${branches_string}$" | # Skip the releases.
while read REVISION REFERENCE; do

  # Skip young branches.
  #[ $(($NOW - $(git log -n 1 --format=%ct $REFERENCE))) -gt $MAX_AGE ] || continue

  # Skip branches that are not from us
  author=`git log -n 1 --format='%cE' $REFERENCE`
  result=`git log -n 1 --format='%cE' $REFERENCE | egrep -v $employees_string`
  [ "$author" == "$result" ] && continue

  MERGED='-'

  # Record whether or not the branch is fully merged into the master or develop branch.
  for (( i=0; i<=$(( $total -1 )); i++ ))
  do
    [ $(git merge-base origin/${BRANCHES[$i]} $REVISION) = $REVISION ] && MERGED="${BRAN[$i]}"
  done

  # Report on old branches.
  printf '%-10s %-75s %s\n' "$MERGED" ${REFERENCE/#refs\/remotes\/origin\//} "$(git log -n 1 --format='%cN <%cE>, %ar' $REFERENCE)"
done | sort -r


#for ref in $(git for-each-ref --sort=-committerdate --format="%(refname)" refs/heads/ refs/remotes ); do
#  git log -n1 $ref --pretty=format:"%Cgreen%cr%Creset %C(yellow)%d%Creset %C(bold blue)<%an>%Creset%n" | cat ;
#done | awk '! a[$0]++'
