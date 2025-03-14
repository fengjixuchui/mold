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

cat <<'EOF' > $t/a.ver
VER_X1 { global: *; local: b*; };
EOF

cat <<EOF | $CXX -fPIC -c -o $t/b.o -xc -
void foo() {}
void bar() {}
void baz() {}
EOF

$CC -B. -shared -Wl,--version-script=$t/a.ver -o $t/c.so $t/b.o

readelf --dyn-syms $t/c.so > $t/log
grep -q 'foo@@VER_X1$' $t/log
! grep -q ' bar$' $t/log || false
! grep -q ' baz$' $t/log || false

echo OK
