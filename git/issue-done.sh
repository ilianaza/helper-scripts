#!/usr/bin/env bash

# Description
# --------------------------
# This script automates tasks necessary after issue has been
# implement. See function clean_local_version for detail explanation
#
# Format: git issue-done [TARGET_BRANCH]
# git issue-done                - by default target branch set to 'master'
# git issue-done release-1.0    - target branch set to 'release-1.0'

# Installation Instructions
# --------------------------
# 1. Clone repo
# 2. chmod 755 ~/helper-scripts/git/issue-done.sh
# 3. ln -s ~/helper-scripts/git/issue-done.sh /usr/local/bin/issue-done
# 4. git config --global alias.issue-done '!bash issue-done'

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

arg1="${1:-}"

# Exit on user demand
exit_on_demand() {
  if [[ "$1" == "q" || "$1" == "quit" ]]
    then
      echo "Exited on user demand!"
      exit
  fi
}

# Check if command argument is present. If not ask for it.
prompt_target_branch() {
  if [ $1 -eq 0 ] ; then
    git branch -avvv
    echo -n "Target branch: "
    read input
    if [[ -z "$input" ]] ; then
      target="master" # default branch is master
    else
      target=$input
    fi
  else
    target="${arg1}"
  fi
}

clean_local_version() {
  # Fetch the latest from origin
  git fetch -tp

  # Checkout target branch
  git checkout $target

  # Catch up with the latest from origin
  git merge $target

  # Remove branches that already been merged into HEAD
  git branch --merged | grep -v "\*" | xargs -n 1 git branch -d

  # Display the list of existing branches
  git branch -avvv
}

prompt_target_branch $#
exit_on_demand $target
clean_local_version $target
exit
