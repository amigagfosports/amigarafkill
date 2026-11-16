#!/bin/sh
# Rafkill for GFOS: host tests.
#   tests/host/run.sh [GFOPENALLEGRO/allegro4]
# The game's datafiles at 16-bit through gfopenallegro's allegro4 core on
# its fake acgame.library; the silent Music class; and the whole game
# (src/ with the GFOS defines and amiga/music_silent.cpp) links on the host
# against that core, so no Allegro or DUMB call is missing.
# Copyright (c) 2026 AmiCradle Team. LGPL-2 or later, as Rafkill.
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
A4=${1:-"$ROOT/../gfopenallegro/allegro4"}
CC=${HOSTCC:-cc}
CXX=${HOSTCXX:-c++}
T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT HUP INT TERM
mkdir -p "$T/a4" "$T/game"
for f in "$A4"/src/a4_*.c "$A4"/tests/fake_acgame.c; do
    "$CC" -std=gnu99 -D_DEFAULT_SOURCE -w -I"$A4/include" -I"$A4/src" -I"$A4/tests" -c "$f" -o "$T/a4/$(basename "$f").o"
done
"$CC" -std=gnu99 -w -I"$A4/include" "$ROOT/tests/host/test_data.c" "$T"/a4/*.o -lm -o "$T/test_data"
"$T/test_data" "$ROOT/data"
"$CXX" -std=gnu++17 -w -I"$ROOT/src" "$ROOT/tests/host/test_music.cpp" "$ROOT/amiga/music_silent.cpp" -o "$T/test_music"
"$T/test_music"
# the whole-game link takes a while: package/build-amiga.sh sets HOST_LINK=0,
# since the stove build links the real thing right after
[ "${HOST_LINK:-1}" = 0 ] && { echo "game: host link skipped (HOST_LINK=0)"; exit 0; }
n=0
cd "$ROOT/src"
for f in $(find . -name '*.cpp' ! -name vector.cpp ! -name music.cpp) ../amiga/music_silent.cpp; do
    "$CXX" -std=gnu++17 -w -D__amigaos__ -I"$A4/include" -I. -c "$f" -o "$T/game/$(echo "$f" | sed 's#^\./##; s#^\.\./##' | tr / _).o"
    n=$((n + 1))
done
"$CXX" -o "$T/rafkill" "$T"/game/*.o "$T"/a4/*.o -lm -lpthread
echo "game: $n sources link on the host"
