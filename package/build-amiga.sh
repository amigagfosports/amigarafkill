#!/bin/sh
# The release, for Cradle's stove_build (os32-gcc16-open6, target package):
#   - gfopenallegro (allegro4.library, liballeg.a) and acgame (acgame.library)
#     built with the same stove at the commits package/package.env pins
#     (or from A4_SRC / ACGAME_SRC when set: checkouts of those repos);
#   - the host tests (tests/host/run.sh, tests/test_part.sh);
#   - the game built by amiga/Makefile.amigaos, with its data;
#   - OUT/Parts/<PART>: a GFOpenUp part (GFOpenUpTool INSTALL Parts/<PART>);
#   - OUT/<NAME>-<VERSION>-68040.lha: the drawer, its icon and the Installer
#     script, with its .sha256 and .readme (tools/pack_dist.py).
# VERSION is the Installer script's $VER. Nothing is published from here.
# Copyright (c) 2026 AmiCradle Team. LGPL-2 or later, as Rafkill.
set -eu

HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ROOT=$(CDPATH= cd -- "$HERE/.." && pwd)
. "$HERE/package.env"
OUT=${OUT:-"$ROOT/build-amiga-package"}
mkdir -p "$OUT"
OUT=$(CDPATH= cd -- "$OUT" && pwd)
cd "$ROOT"
t0=$(date +%s)

# A stove's compiler is in its prefix/ (or STOVE is the prefix itself).
if [ -x "$STOVE/prefix/bin/m68k-amigaos-gcc" ]; then KIT="$STOVE"; else KIT=$(dirname "$STOVE"); fi
PREFIX="$KIT/prefix"

DEPS="$OUT/deps"
mkdir -p "$DEPS"
fetch() {   # fetch <repo> <ref> <dir>
    if [ ! -d "$3/.git" ]; then
        git init -q "$3" && git -C "$3" remote add origin "https://github.com/DalsinAI/$1"
    fi
    git -C "$3" fetch -q --depth 1 origin "$2" && git -C "$3" checkout -q --detach FETCH_HEAD
    echo "$1 at $(git -C "$3" rev-parse HEAD)"
}
if [ -z "${A4_SRC:-}" ]; then A4_SRC="$DEPS/gfopenallegro"; fetch gfopenallegro "$GFOPENALLEGRO_REF" "$A4_SRC"; fi
if [ -z "${ACGAME_SRC:-}" ]; then ACGAME_SRC="$DEPS/acgame"; fetch acgame "$ACGAME_REF" "$ACGAME_SRC"; fi
A4="$A4_SRC/allegro4"
STOVE="$KIT" OUT="$DEPS/a4-out" sh "$A4/build-amiga.sh" > "$OUT/deps-output.txt" 2>&1 || { tail -n 40 "$OUT/deps-output.txt"; exit 1; }
STOVE="$KIT" OUT="$DEPS/acgame-out" sh "$ACGAME_SRC/build-amiga.sh" >> "$OUT/deps-output.txt" 2>&1 || { tail -n 40 "$OUT/deps-output.txt"; exit 1; }
grep -E '\.library \(' "$OUT/deps-output.txt"

sh tests/test_part.sh
if command -v "${HOSTCC:-cc}" >/dev/null 2>&1; then
    HOST_LINK=0 sh tests/host/run.sh "$A4"
else
    echo "no host C compiler: datafile read-back skipped"
fi

make -f amiga/Makefile.amigaos PREFIX="$PREFIX" A4="$A4" A4OUT="$DEPS/a4-out" ACGOUT="$DEPS/acgame-out" \
    -j4 $TARGET > "$OUT/build-output.txt" 2>&1 || { tail -n 60 "$OUT/build-output.txt"; exit 1; }

VERSION=$(sed -n '1s/^; \$VER: [^ ]* \([^ ]*\) (.*/\1/p' amiga/Install-"$NAME")
sh tools/write_part.sh "$DIST" "$NAME" "$OUT/Parts" "$PART" "$VERSION" "$ABOUT" "$NEEDS"
echo "part: Parts/$PART $VERSION, $(grep -c '^copy' "$OUT/Parts/$PART/Part") files, $(du -sk "$OUT/Parts/$PART" | cut -f1) KB"

python3 "$ROOT/tools/pack_dist.py" --dist "$DIST" --name "$NAME" --out "$OUT"
ls -l "$DIST/$NAME/$NAME" "$DIST/$NAME/data/raptor.dat"
echo "total: $(( $(date +%s) - t0 )) s"
