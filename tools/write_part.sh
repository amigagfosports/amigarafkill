#!/bin/sh
# A GFOpenUp part from a built drawer, so the game installs on GFOS with
#   GFOpenUpTool INSTALL Parts/<PART>
# Lays the drawer out as it goes (Games/<DRAWER>/..., Games/<DRAWER>.info)
# in <PARTS>/<PART>/ and writes the Part file GFOpenUpTool reads (gfopenup
# src/openuptool.c): one "copy" line per file, to SYS:<its path>.
#   write_part.sh <dist> <drawer> <parts> <part> <version> <about> [<needs parts>]
# <needs parts>: the GFOpenUp parts the game needs, space-separated (none
# for Liquid War 5: it carries its own Libs/).
# <dist> holds <drawer>/ and <drawer>.info (the Makefile's build/amigaos).
# The User drawer (settings, saves, high scores) is never in the part: the
# game makes it, and a REMOVE leaves it.
# MIT, Copyright (c) 2026 AmiCradle Team.
set -eu
DIST=$1; D=$2; PARTS=$3; PART=$4; V=$5; ABOUT=$6; NEEDS=${7:-}
P="$PARTS/$PART"
rm -rf "$P"; mkdir -p "$P/Games"
cp -R "$DIST/$D" "$P/Games/$D"
rm -rf "$P/Games/$D/User" "$P/Games/$D/User.info"
cp "$DIST/$D.info" "$P/Games/$D.info"
{
    echo "part $PART $V"
    echo "; $ABOUT"
    echo "needs 68040"
    for n in $NEEDS; do echo "needs part $n"; done
    (cd "$P" && find Games -type f | LC_ALL=C sort) | while read -r f; do
        echo "copy \"$f\" \"SYS:$f\""
    done
} > "$P/Part.new"
mv "$P/Part.new" "$P/Part"
