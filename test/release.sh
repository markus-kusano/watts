#!/bin/bash
# Same as run.sh but uses the optimized build
set -u

source exports.sh

die () {
  if [ ! -z "${@:-}" ]
  then
    echo ${@}
  fi
  exit 1
}

# Compare the two passed file names. Crash if they are different
cmpOrWarn () {
  if [ -z ${1:-} ]
  then
    die "cmpOrDie(): no first argument"
  fi

  if [ -z ${2:-} ]
  then
    die "cmpOrDie(): no second argument"
  fi

  if [ ! -f "$1" ]
  then
    die "cmpOrDie(): $1: file not found"
  fi
  if [ ! -f "$2" ]
  then
    die "cmpOrDie(): $2: file not found"
  fi

  diff $1 $2 
  res=$?

  if [ "$res" -ne "0" ]
  then
    echo "WARNING: $1 does not match $2"
  fi
}

if [ -z ${1:-} ]
then
  die "First argument must be program to test"
fi

if [ ! -d ${1:-} ]
then
  die "Directory not found: $1"
fi

cd $1

# Build the .bc file
$CLANG -emit-llvm -S -c main.c 

# run opt (box domain)
echo "Testing Box"
time $OPT -load $WORKLIST_OPT_SO -worklist-ai  -box main.ll >main_out.bc 2>box.out || die "[ERROR]: opt (box)"
cmpOrWarn box.out box.exp

# Oct domain
echo "Testing Oct"
time $OPT -load $WORKLIST_OPT_SO -worklist-ai -oct main.ll >main_out.bc 2>oct.out || die "[ERROR]: opt (oct)"
cmpOrWarn oct.out oct.exp

# go back to where we started
cd - >& /dev/null
