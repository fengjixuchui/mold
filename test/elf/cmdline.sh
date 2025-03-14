#!/bin/bash
export LC_ALL=C
set -e
CC="${TEST_CC:-cc}"
CXX="${TEST_CXX:-c++}"
GCC="${TEST_GCC:-gcc}"
GXX="${TEST_GXX:-g++}"
MACHINE="${MACHINE:-$(uname -m)}"
testname=$(basename "$0" .sh)
echo -n "Testing $testname ... "
t=out/test/elf/$MACHINE/$testname
mkdir -p $t

{ ./mold -zfoo || true; } 2>&1 | grep -q 'unknown command line option: -zfoo'
{ ./mold -z foo || true; } 2>&1 | grep -q 'unknown command line option: -z foo'
{ ./mold -abcdefg || true; } 2>&1 | grep -q 'unknown command line option: -abcdefg'
{ ./mold --abcdefg || true; } 2>&1 | grep -q 'unknown command line option: --abcdefg'

echo OK
