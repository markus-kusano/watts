#!/bin/sh
# Run all tests

source ./testdirs.sh

# Ensure that all the test directories exist upfront
for d in $TEST_DIRS
do
  if [ ! -d "$d" ] 
  then
    echo "Test directory not found: $d"
    exit 1
  fi
done

for d in $TEST_DIRS
do
  echo "Testing $d"
  ./run.sh $d || exit 1
  echo "Test passed"
done
