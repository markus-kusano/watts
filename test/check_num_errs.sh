#!/bin/bash
# Check the number of errors found by the abstract interpreter for various
# testing methods.
#
# The input to the script should be a directory to examine
#
# This expects: (1) the file containing the output of the test (e.g.,
# box_ncomb.out) and a file with the expected number of errors found (e.g.,
# box_ncomb.errs).

set -u

source ./funcs.sh

if [ -z "${1:-}" ]
then
  die 'ERROR: first arg should be a directory to test'
fi

if [ ! -d "${1:-}" ]
then
  die "ERROR: first arg is not a directory ($1)"
fi

cd $1

check_results box_ncomb
check_results box_comb
check_results box_constr
check_results box_slice
check_results oct_ncomb
check_results oct_comb
check_results oct_constr
check_results oct_slice

cd -
