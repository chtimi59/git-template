#!/bin/sh
set -e
ROOT=`dirname $0`
cd "$ROOT/utest"

./init.sh

echo "success"