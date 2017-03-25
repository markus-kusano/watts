#!/bin/sh
# Run all tests

# Import the generic commands to run tests and stuff
source ./funcs.sh

set -u

TEMP_TABLE=/tmp/box_table000

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

rm -f $TEMP_TABLE
for d in $TEST_DIRS
do
  ./get_box_stats.sh $d >>$TEMP_TABLE
done

cat $TEMP_TABLE
NCOMB_TOTAL_TIME=$(awk -F'&' '{ sum+=$2} END {print sum}' $TEMP_TABLE)
NCOMB_TOTAL_VERIF=$(awk -F'&' '{ sum+=$3} END {print sum}' $TEMP_TABLE)
COMB_TOTAL_TIME=$(awk -F'&' '{ sum+=$4} END {print sum}' $TEMP_TABLE)
COMB_TOTAL_VERIF=$(awk -F'&' '{ sum+=$5} END {print sum}' $TEMP_TABLE)
CONSTR_TOTAL_TIME=$(awk -F'&' '{ sum+=$6} END {print sum}' $TEMP_TABLE)
CONSTR_TOTAL_VERIF=$(awk -F'&' '{ sum+=$7} END {print sum}' $TEMP_TABLE)
SLICE_TOTAL_TIME=$(awk -F'&' '{ sum+=$8} END {print sum}' $TEMP_TABLE)
SLICE_TOTAL_VERIF=$(awk -F'&' '{ sum+=$9} END {print sum}' $TEMP_TABLE)
echo "Total 
      & $NCOMB_TOTAL_TIME
      & $NCOMB_TOTAL_VERIF
      & $COMB_TOTAL_TIME
      & $COMB_TOTAL_VERIF
      & $CONSTR_TOTAL_TIME
      & $CONSTR_TOTAL_VERIF
      & $SLICE_TOTAL_TIME
      & $SLICE_TOTAL_VERIF"
