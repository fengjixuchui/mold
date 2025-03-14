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

cat <<EOF | $CC -o $t/a.o -c -xc -
int main() {
  return 0;
}
EOF

$CC -B. -Wl,--no-eh-frame-hdr -Wl,--thread-count=1 -O0 -o $t/exe $t/a.o

readelf -WS $t/exe > $t/log
! grep -F .eh_frame_hdr $t/log || false

$QEMU $t/exe

echo OK
