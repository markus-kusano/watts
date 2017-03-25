#!/bin/sh

find . -name '*.out' | xargs rm -f
find . -name '*.smt2' | xargs rm -f
find . -name '*.time' | xargs rm -f
find . -name '*.bc' | xargs rm -f
find . -name '*.ll' | xargs rm -f
find . -name 'z3_out.tmp' -type f | xargs rm -f
find . -name '*.diff' | xargs rm -f
