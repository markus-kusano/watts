#!/bin/sh
set -u

die () {
  if [ ! -z "${@:-}" ]
  then
    echo ${@}
  fi
  exit 1
}

cd $1
echo "clang -emit-llvm -S -c main.c"
clang -emit-llvm -S -c main.c  || die "error: clang"

ASSERT_STR='.*call void @__assert_fail.*'
#ASSERT_STR='__assert_fail'

echo "Num asserts: $(egrep "$ASSERT_STR" main.ll | wc -l)"
cd -

