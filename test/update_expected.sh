#!/bin/sh

set -u

cd $1 || exit 1

for f in `ls *.out`
do
  # file name prefix
  PREF="${f%.*}"
  echo "cp $f ${PREF}.exp"
  cp "$f" "${PREF}.exp" || exit 1
done
