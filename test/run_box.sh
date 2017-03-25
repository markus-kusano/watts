#!/bin/sh

# run all box related tests for a single passed directory
set -u

# Import the generic commands to run tests and stuff
source ./funcs.sh

if [ -z "${1:-}" ]
then
  die "First argument must be program to test"
fi


if [ ! -d "${1:-}" ] 
then
  echo "Test directory not found: $1"
  exit 1
fi

echo "Testing $1"
cd $1
build_main
run_box_ncomb
run_box_comb
run_box_constr
gen_pdg
run_box_pdg
cd -
