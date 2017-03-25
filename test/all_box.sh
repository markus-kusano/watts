#!/bin/sh
# Run all tests

# Import the generic commands to run tests and stuff
source ./funcs.sh

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
  cd $d
  build_main
  run_box_ncomb
  run_box_comb
  run_box_constr
  gen_pdg
  run_box_pdg
  run_box_slice
  cd -
  echo "Test passed"
done
