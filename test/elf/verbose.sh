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

cat <<EOF | $CC -c -xc -o $t/a.o -
#include <stdio.h>

int main() {
  printf("Hello world\n");
}
EOF

$CC -B. -Wl,--verbose -o $t/exe $t/a.o > /dev/null

echo OK
