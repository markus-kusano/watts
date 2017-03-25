#!/bin/bash

set -u

source ./funcs.sh
source ./testdirs.sh

for d in $TEST_DIRS
do
  cd $d

  if [ ! -f duet.out ]
  then
    echo "[ERROR] duet output not found in $d"
    exit 1
  fi
  #grep 'Assertion failed:' duet.out
  grep 'safe assertions' duet.out

  cd - >/dev/null
done
