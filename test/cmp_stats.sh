#!/bin/bash
# Compare the expected and output of the passed directory
# This assume the output files (*.out) from running the test exists. Use
# ./run.sh
# 
# Note: there is no expected time value: re-running the test over-writes the
# *.time files. So, the expected (*.exp) and *.out files will always havwe the
# same time (i.e., the time will be the same in get_stats.sh and
# get_exp_stats.sh)
set -u

die () {
  if [ ! -z "${@:-}" ]
  then
    echo ${@}
  fi
  exit 1
}


if [ -z ${1:-} ]
then
  die "First argument must be program (directory) to test"
fi

if [ ! -d ${1:-} ]
then
  die "Directory not found: $1"
fi

diff <(./get_stats.sh $1 ) <(./get_exp_stats.sh $1 )
