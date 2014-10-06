#!/usr/bin/sh

# This script is a shortcut for basic routine git commands

set -x # Output executed commands
set -e # Fail script if one command fails

read MESSAGE

git add -A
git commit -m "$MESSAGE"
git push origin master
