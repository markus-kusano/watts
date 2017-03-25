#!/bin/bash
# Subset of run.sh where only the constraint analysis is run
set -u
source exports.sh

# Max time, passed to timeout command. Can be something like 1s, 30m, or 2h (seconds, minutes, hours)
MAX_TIME=30m

TIMEOUT="timeout $MAX_TIME"

# arguments to pass to every abstract interpreter pass
#AI_ARGS="-nodebug"
AI_ARGS=""

die () {
  if [ ! -z "${@:-}" ]
  then
    echo ${@}
  fi
  exit 1
}

# Compare the two passed file names. Crash if they are different
cmpOrDie () {
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
    die "$1 does not match $2"
  fi
}

# Compare the two passed file names. Warn if they are different
cmpOrWarn () {
  if [ -z "${1:-}" ]
  then
    die "cmpOrDie(): no first argument"
  fi

  if [ -z "${2:-}" ]
  then
    die "cmpOrDie(): no second argument"
  fi

  if [ ! -f "$1" ]
  then
    die "cmpOrDie(): $1: file not found"
  fi
  if [ ! -f "$2" ]
  then
    #die "cmpOrDie(): $2: file not found"
    echo "[WARNING] cmpOrDie(): $2: file not found"
  fi

  diff $1 $2 
  res=$?

  if [ "$res" -ne "0" ]
  then
    echo "[WARNING] $1 does not match $2"
  fi
}

# $1 should be the return code of a process run with timeout. $2
# should be a log file to write the timeout information to. $3 should be an error message associated with the command being checked. This will be displayed if the command exited with an error code
#
# If the return code is 124, then the process timedout. Write this to the log file ($2). If the return code is zero, then sucess. Otherwise, error; this function will call die and close the script
check_timeout() {
  if [ -z "${1:-}" ]
  then
    die "check_timeout(): no first argument"
  fi

  if [ -z "${2:-}" ]
  then
    die "check_timeout(): no second argument"
  fi

  if [ -z "${3:-}" ]
  then
    die "check_timeout(): no third argument"
  fi

  if [ "$1" -eq "124" ]
  then 
    echo "TIMEOUT"
  elif [ "$1" -ne "0" ]
  then
    die "$3"
  fi
  # passed :)
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

# Make sure we use the time binary and not the builtin shell command
TIME="`which time` -f %e"

# Build the .bc file
echo "$CLANG -emit-llvm -S -c main.c"
$CLANG -emit-llvm -S -c main.c  || die "error: clang"

run_box_constr() {
# run opt box domain with combinaional exploration with constraints
date
#$TIME -o box_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -box main.ll >main_out.bc 2>box_constr.out || die "[ERROR]: opt (box constr)" 
$TIMEOUT $TIME -o box_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -box main.ll >main_out.bc 2>box_constr.out 
ret=$?
check_timeout $ret box_constr.out "[ERROR]: opt (box constr)" 
cmpOrWarn box_constr.out box_constr.exp
echo "Box Constraints Passed"
}

run_oct_constr() {
# run opt oct domain with combinaional exploration with constraints
if [ ! -f "no_oct_constr" ]
then
  date
  #$TIME -o oct_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -oct main.ll >main_out.bc 2>oct_constr.out || die "[ERROR]: opt (oct constr)" 
  $TIMEOUT $TIME -o oct_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -oct main.ll >main_out.bc 2>oct_constr.out 
  ret=$?
  check_timeout $ret oct_constr.out "[ERROR]: opt (oct constr)" 
  cmpOrWarn oct_constr.out oct_constr.exp
  echo "Oct Constraints Passed"
else 
  echo "Oct constraints skipped"
fi
}

run_box_constr
run_oct_constr

cd -
