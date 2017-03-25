#!/bin/bash

# For all the test types, if the output of the test exists create a file
# containing the number of errors found in the test. E.g., if the box_ncomb.out
# file exists then create a file box_ncomb.errs containing the number of errors
# found. This is used in conjunction with check_num_errs.sh to perform testing.
#
# Input to the script should be a directory to update

set -u

die () {
  if [ ! -z "${@:-}" ]
  then
    echo ${@}
  fi
  exit 1
}

# $1 should be a prefix of a test (e.g., "box_ncomb"). This adds the number of
# errors to the corresponding .errs file
add_errs() {
  if [ -z "${1:-}" ]
  then
    die 'ERROR: add_errs(): first argument is empty'
  fi

  if [ -f "${1}.out" ]
  then
    errString=$(grep 'Errors found: ' ${1}.out)

    if [ "$?" -ne "0" ]
    then
      die 'ERROR: add_errs(): error string not found in output'
    fi

    # chop off the "Errors found: " in the output, store into a file
    echo $errString | sed 's/Errors found: //' > ${1}.errs
  else 
    echo "WARNING: $1 output not found"
  fi
}


if [ -z "${1:-}" ]
then
  die 'ERROR: first arg should be a directory to test'
fi

if [ ! -d "${1:-}" ]
then
  die "ERROR: first arg is not a directory ($1)"
fi

cd $1
  add_errs box_ncomb
  add_errs box_comb
  add_errs box_constr
  add_errs box_slice
  add_errs oct_ncomb
  add_errs oct_comb
  add_errs oct_constr
  add_errs oct_slice
  add_errs box_tso
  add_errs box_pso

  cat box_ncomb.errs
  cat box_comb.errs
  cat box_constr.errs
  cat box_slice.errs
  echo "weak"
  cat box_tso.errs
  cat box_pso.errs

cd - >/dev/null
