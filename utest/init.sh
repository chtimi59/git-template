#!/bin/sh
set -e
echo --- $0 ---
D="$HOME/git-test.tmp"
rm -rf $D
mkdir -p $D
cd $D
# ------

git init
git template init
git template lock
git template config core.sha master
git template config core.sha
git template unlock
