#!/bin/sh
set -e
UTESTFOLDER=$(cd `dirname $0` | pwd)/utest
OUTPUTPATH="$HOME/git-test.tmp"
rm -rf $OUTPUTPATH
mkdir -p $OUTPUTPATH
cd $OUTPUTPATH

TESTTITLE_COLOR=$'\e[1;35m'
TESTFAIL_COLOR=$'\e[1;37m\e[41m'
TESTSUCCESS_COLOR=$'\e[1;37m\e[42m'
CLEAR_COLOR=$'\e[0m'

startTest() {
    local NAME=`basename $1 | sed 's/\.sh//g'`
    echo $TESTTITLE_COLOR"[ "$NAME" ]"$CLEAR_COLOR
    # create sand box folder
    rm -rf $NAME; [ $? != 0 ] && exit 1
    mkdir -p $NAME; [ $? != 0 ] && exit 1
    pushd $NAME >/dev/null 2>&1 ;[ $? != 0 ] && exit 1
    # execute test
    $1 || exit 1
    # test end
    popd >/dev/null 2>&1; [ $? != 0 ] && exit 1
    echo $TESTSUCCESS_COLOR"Success"$CLEAR_COLOR
}

{
    find $UTESTFOLDER -name "*.sh" | while read f
    do
        startTest "$f"
    done
} || {
    pwd
    echo $TESTFAIL_COLOR"Failed"$CLEAR_COLOR
    exit 1
}