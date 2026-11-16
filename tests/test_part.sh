#!/bin/sh
# Host test for tools/write_part.sh: the GFOpenUp part's layout and Part file.
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
HERE=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
mkdir -p "$T/dist/Game/graphics" "$T/dist/Game/User"
: > "$T/dist/Game/Game"; : > "$T/dist/Game/graphics/title.pcx"
: > "$T/dist/Game/User/globalsettings.dat"; : > "$T/dist/Game/User.info"; : > "$T/dist/Game.info"
sh "$HERE/../tools/write_part.sh" "$T/dist" Game "$T/Parts" Game 1.0-gfos1 "A test game"
P="$T/Parts/Game/Part"; fail=0
expect() { grep -qxF "$1" "$P" || { echo "FAIL: no line: $1"; fail=1; }; }
[ "$(head -1 "$P")" = 'part Game 1.0-gfos1' ] || { echo "FAIL: first line"; fail=1; }
expect 'needs 68040'
grep -q '^needs part' "$P" && { echo "FAIL: a needs part line with none asked for"; fail=1; }
expect 'copy "Games/Game/Game" "SYS:Games/Game/Game"'
expect 'copy "Games/Game/graphics/title.pcx" "SYS:Games/Game/graphics/title.pcx"'
expect 'copy "Games/Game.info" "SYS:Games/Game.info"'
grep -q 'User' "$P" && { echo "FAIL: the player's User drawer is in the part"; fail=1; }
grep -q '"Games/Part' "$P" && { echo "FAIL: the Part file lists itself"; fail=1; }
[ "$(grep -c '^copy' "$P")" = 3 ] || { echo "FAIL: copy count"; fail=1; }
sh "$HERE/../tools/write_part.sh" "$T/dist" Game "$T/Parts" Game 1.0-gfos1 "A test game"
[ "$(grep -c '^copy' "$P")" = 3 ] || { echo "FAIL: a second run differs"; fail=1; }
sh "$HERE/../tools/write_part.sh" "$T/dist" Game "$T/Parts" Game 1.0-gfos1 "A test game" "GFOpenGPU AHI"
expect 'needs part GFOpenGPU'
expect 'needs part AHI'
[ $fail = 0 ] && echo "GFOpenUp part: all checks passed"
exit $fail
