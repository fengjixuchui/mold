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

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
void foo() {}
EOF

$CC -o $t/b.so -shared $t/a.o
readelf --dynamic $t/b.so > $t/log
! grep -Fq 'Library soname' $t/log || false

$CC -B. -o $t/b.so -shared $t/a.o -Wl,-soname,foo
readelf --dynamic $t/b.so | grep -Fq 'Library soname: [foo]'

echo OK
