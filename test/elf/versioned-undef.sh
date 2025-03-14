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

# Skip if libc is musl because musl does not fully support GNU-style
# symbol versioning.
ldd --help 2>&1 | grep -q musl && { echo skipped; exit; }

cat <<EOF | $CC -fPIC -c -o $t/a.o -xc -
int foo1() { return 1; }
int foo2() { return 2; }
int foo3() { return 3; }

__asm__(".symver foo1, foo@VER1");
__asm__(".symver foo2, foo@VER2");
__asm__(".symver foo3, foo@@VER3");
EOF

echo 'VER1 { local: *; }; VER2 { local: *; }; VER3 { local: *; };' > $t/b.ver
$CC -B. -shared -o $t/c.so $t/a.o -Wl,--version-script=$t/b.ver

cat <<EOF | $CC -c -o $t/d.o -xc -
#include <stdio.h>

int foo1();
int foo2();
int foo3();
int foo();

__asm__(".symver foo1, foo@VER1");
__asm__(".symver foo2, foo@VER2");
__asm__(".symver foo3, foo@VER3");

int main() {
  printf("%d %d %d %d\n", foo1(), foo2(), foo3(), foo());
}
EOF

$CC -B. -o $t/exe $t/d.o $t/c.so
$QEMU $t/exe | grep -q '^1 2 3 3$'

echo OK
