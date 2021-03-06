#!/bin/sh
set -e
git init --bare repo.git
git template init
git template unlock
mkdir .template/repo/content/%%SRC%%/
echo %%INPUT%% > .template/repo/content/%%SRC%%/%%MAIN%%.template
git template add .
git template commit -m "initial"
git template remote add origin $(pwd)/repo.git
git template remote -v
git template push --set-upstream origin master
git template lock
git template remove
git template clone repo.git


