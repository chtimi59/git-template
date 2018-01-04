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
git template unlock

printf "int a=%%A%%;\r\n" > ./.template/repo/content/foo.c
mkdir ./.template/repo/content/%%SRC%%
printf "int b=%%b%%;\r\n" > ./.template/repo/content/%%SRC%%/bar.c
git template add .
git template commit -m "initial"

git template lock

