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

[ $MACHINE = ppc64le ] && { echo skipped; exit; }

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
#include <stdio.h>

extern char foo;

int main() {
  printf("%lx\n", (unsigned long)&foo);
}
EOF

$CC -B. -no-pie -o $t/exe $t/a.o -Wl,-defsym=foo=_GLOBAL_OFFSET_TABLE_

$QEMU $t/exe > /dev/null
GOT_ADDR=$($QEMU $t/exe)

# _GLOBAL_OFFSET_TABLE_ refers the end of .got only on x86.
# We assume .got is followed by .gotplt.
if [ $MACHINE = x86_64 -o $MACHINE = i386 -o $MACHINE = i686 ]; then
  readelf -WS $t/exe | grep -q "\.got\.plt .*$GOT_ADDR "
else
  readelf -WS $t/exe | grep -q "\.got .*$GOT_ADDR "
fi

echo OK
