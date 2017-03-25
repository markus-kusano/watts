#!/bin/bash
set -u

# run all box and oct related tests for a single passed directory
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
gen_pdg
run_box_ncomb
run_box_comb
run_box_constr
run_box_pdg
run_oct_ncomb
run_oct_comb
run_oct_constr
run_oct_pdg
cd -

#source exports.sh
#
## Max time, passed to timeout command. Can be something like 1s, 30m, or 2h (seconds, minutes, hours)
#MAX_TIME=30m
#
#TIMEOUT="timeout $MAX_TIME"
#
## arguments to pass to every abstract interpreter pass
#AI_ARGS="-nodebug"
##AI_ARGS=""
#
#die () {
#  if [ ! -z "${@:-}" ]
#  then
#    echo ${@}
#  fi
#  exit 1
#}
#
## Compare the two passed file names. Crash if they are different
#cmpOrDie () {
#  if [ -z ${1:-} ]
#  then
#    die "cmpOrDie(): no first argument"
#  fi
#
#  if [ -z ${2:-} ]
#  then
#    die "cmpOrDie(): no second argument"
#  fi
#
#  if [ ! -f "$1" ]
#  then
#    die "cmpOrDie(): $1: file not found"
#  fi
#  if [ ! -f "$2" ]
#  then
#    die "cmpOrDie(): $2: file not found"
#  fi
#
#  diff $1 $2 
#  res=$?
#
#  if [ "$res" -ne "0" ]
#  then
#    die "$1 does not match $2"
#  fi
#}
#
## Compare the two passed file names. Warn if they are different
#cmpOrWarn () {
#  if [ -z "${1:-}" ]
#  then
#    die "cmpOrDie(): no first argument"
#  fi
#
#  if [ -z "${2:-}" ]
#  then
#    die "cmpOrDie(): no second argument"
#  fi
#
#  if [ ! -f "$1" ]
#  then
#    die "cmpOrDie(): $1: file not found"
#  fi
#  if [ ! -f "$2" ]
#  then
#    #die "cmpOrDie(): $2: file not found"
#    echo "[WARNING] cmpOrDie(): $2: file not found"
#  fi
#
#  diff $1 $2 
#  res=$?
#
#  if [ "$res" -ne "0" ]
#  then
#    echo "[WARNING] $1 does not match $2"
#  fi
#}
#
## $1 should be the return code of a process run with timeout. $2
## should be a log file to write the timeout information to. $3 should be an error message associated with the command being checked. This will be displayed if the command exited with an error code
##
## If the return code is 124, then the process timedout. Write this to the log file ($2). If the return code is zero, then sucess. Otherwise, error; this function will call die and close the script
#check_timeout() {
#  if [ -z "${1:-}" ]
#  then
#    die "check_timeout(): no first argument"
#  fi
#
#  if [ -z "${2:-}" ]
#  then
#    die "check_timeout(): no second argument"
#  fi
#
#  if [ -z "${3:-}" ]
#  then
#    die "check_timeout(): no third argument"
#  fi
#
#  if [ "$1" -eq "124" ]
#  then 
#    echo "TIMEOUT"
#  elif [ "$1" -ne "0" ]
#  then
#    die "$3"
#  fi
#  # passed :)
#}
#
#if [ -z ${1:-} ]
#then
#  die "First argument must be program to test"
#fi
#
#if [ ! -d ${1:-} ]
#then
#  die "Directory not found: $1"
#fi
#
#cd $1
#
## Make sure we use the time binary and not the builtin shell command
#TIME="`which time` -f %e"
#
## Build the .bc file
#echo "$CLANG -emit-llvm -S -c main.c"
#$CLANG -emit-llvm -S -c main.c  || die "error: clang"
#
## run box domain non-combinational interference exploration
#echo "$TIME -o box_ncomb.time $OPT -load $WORKLIST_SO -worklist-ai  -nocombs -box main.ll >main_out.bc 2>box_ncomb.out"
#date
##$TIME -o box_ncomb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -nocombs -box main.ll >main_out.bc 2>box_ncomb.out || die "[ERROR]: opt (box ncomb)" 
#$TIMEOUT $TIME -o box_ncomb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -nocombs -box main.ll >main_out.bc 2>box_ncomb.out 
#ret=$?
#check_timeout $ret box_ncomb.out "[ERROR]: opt (box ncomb)" 
##cmpOrWarn box_ncomb.out box_ncomb.exp
#cmpOrWarn box_ncomb.out box_ncomb.exp
#echo "Box Non-combinational Passed"
#
## run oct no combinations. the special file allows the test to be skipped
#if [ ! -f "no_oct_ncomb" ]
#then
#  date
#  #$TIME -o oct_ncomb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -nocombs -oct main.ll >main_out.bc 2>oct_ncomb.out || die "[ERROR]: opt (oct ncomb)" 
#  $TIMEOUT $TIME -o oct_ncomb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -nocombs -oct main.ll >main_out.bc 2>oct_ncomb.out
#  ret=$?
#  check_timeout $ret cot_ncomb.out "[ERROR]: opt (oct ncomb)" 
#  cmpOrWarn oct_ncomb.out oct_ncomb.exp
#  echo "Oct Non-combinational Passed"
#else
#  echo "Skipping Oct Non-combinational"
#fi
#
## run opt box domain with combinaional exploration (no constraints)
#date
#echo "$OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -box main.ll >main_out.bc 2>box_comb.out"
##$TIME -o box_comb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -box main.ll >main_out.bc 2>box_comb.out || die "[ERROR]: opt (box comb)" 
#$TIMEOUT $TIME -o box_comb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -box main.ll >main_out.bc 2>box_comb.out
#ret=$?
#check_timeout $ret box_comb.out "[ERROR]: opt (box comb)"
#cmpOrWarn box_comb.out box_comb.exp
#echo "Box Combinational Passed"
#
## run opt oct domain with combinaional exploration (no constraints)
#if [ ! -f "no_oct_comb" ]
#then
#  date
#  #$TIME -o oct_comb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -oct main.ll >main_out.bc 2>oct_comb.out || die "[ERROR]: opt (oct comb)"
#  $TIMEOUT $TIME -o oct_comb.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -oct main.ll >main_out.bc 2>oct_comb.out 
#  ret=$?
#  check_timeout $ret oct_comb.out "[ERROR]: opt (oct comb)"
#  cmpOrWarn oct_comb.out oct_comb.exp
#  echo "Oct Combinational Passed"
#else
#  echo "Oct Combinational Skipped"
#fi
#
## run opt box domain with combinaional exploration with constraints
#date
##$TIME -o box_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -box main.ll >main_out.bc 2>box_constr.out || die "[ERROR]: opt (box constr)" 
#$TIMEOUT $TIME -o box_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -box main.ll >main_out.bc 2>box_constr.out 
#ret=$?
#check_timeout $ret box_constr.out "[ERROR]: opt (box constr)" 
#cmpOrWarn box_constr.out box_constr.exp
#echo "Box Constraints Passed"
#
## run opt oct domain with combinaional exploration with constraints
#if [ ! -f "no_oct_constr" ]
#then
#  date
#  #$TIME -o oct_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -oct main.ll >main_out.bc 2>oct_constr.out || die "[ERROR]: opt (oct constr)" 
#  $TIMEOUT $TIME -o oct_constr.time $OPT -load $WORKLIST_SO -worklist-ai $AI_ARGS -constraints -z3 $Z3_BIN -oct main.ll >main_out.bc 2>oct_constr.out 
#  ret=$?
#  check_timeout $ret oct_constr.out "[ERROR]: opt (oct constr)" 
#  cmpOrWarn oct_constr.out oct_constr.exp
#  echo "Oct Constraints Passed"
#else 
#  echo "Oct constraints skipped"
#fi
#
## generate the PDG
#echo "$OPT -load $DYN_PDG_SO -contextinsen-dynpdg -mdassert -assert -z3 $Z3_BIN main.ll >main_pdg.bc"
##$TIME -o pdg.time $OPT -load $DYN_PDG_SO -contextinsen-dynpdg -mdassert -assert -z3 $Z3_BIN main.ll >main_pdg.bc 2>pdg.out || die "[ERROR]: opt (pdg)" 
#$TIMEOUT $TIME -o pdg.time $OPT -load $DYN_PDG_SO -contextinsen-dynpdg -mdassert -assert -z3 $Z3_BIN main.ll >main_pdg.bc 2>pdg.out
#ret=$?
#check_timeout $ret pdg.out "[ERROR]: opt (pdg)" 
#echo "PDG Generated"
#llvm-dis main_pdg.bc
#
## If the file "no_slice" exists then the slice tests will not be run
#if [ ! -f "no_slice" ]
#then
#	# run box with assert slice
#  date
#	#$TIME -o box_slice.time $OPT -load $WORKLIST_SO -worklist-ai -aslice $AI_ARGS -constraints -z3 $Z3_BIN -box main_pdg.ll >main_out.bc 2>box_slice.out || die "[ERROR]: opt (box slice)" 
#	$TIMEOUT $TIME -o box_slice.time $OPT -load $WORKLIST_SO -worklist-ai -aslice $AI_ARGS -constraints -z3 $Z3_BIN -box main_pdg.ll >main_out.bc 2>box_slice.out 
#  ret=$?
#  check_timeout $ret box_slice.out "[ERROR]: opt (box slice)" 
#	cmpOrWarn box_slice.out box_slice.exp
#	echo "Box Slice passed"
#	# Calculate the PDG creation time and the abstract interpretation time
#	echo `cat box_slice.time` + `cat pdg.time` | bc >box_slice_pdg.time
#fi
#
#if [ ! -f "no_slice" ]
#then
#  if [ ! -f "no_oct_slice" ]
#  then
#    # run oct with assert slice
#    date
#    #$TIME -o oct_slice.time $OPT -load $WORKLIST_SO -worklist-ai -aslice $AI_ARGS -constraints -z3 $Z3_BIN -oct main_pdg.ll >main_out.bc 2>oct_slice.out || die "[ERROR]: opt (oct slice)" 
#    $TIMEOUT $TIME -o oct_slice.time $OPT -load $WORKLIST_SO -worklist-ai -aslice $AI_ARGS -constraints -z3 $Z3_BIN -oct main_pdg.ll >main_out.bc 2>oct_slice.out 
#    ret=$?
#    check_timeout $ret oct_slice.out "[ERROR]: opt (oct slice)" 
#    cmpOrWarn oct_slice.out oct_slice.exp
#    echo "Oct Slice passed"
#    # Calculate the PDG creation time and the abstract interpretation time
#    echo `cat oct_slice.time` + `cat pdg.time` | bc >oct_slice_pdg.time
#  else 
#    echo "Oct slice skipped"
#  fi
#fi
#
## go back to where we started
#cd - >& /dev/null
