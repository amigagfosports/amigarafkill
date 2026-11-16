# Rafkill for GFOS

Rafkill 1.2.4 by Jon Rafkind (LGPL-2), from the author's own
https://github.com/kazzmir/rafkill at commit
daecbaa72f51d940b550051a34245ade6c6966ad, built for
AmigaOS 3.2 / GFOS on a 68040, 68060 or 68080. No FPU is needed.

A vertical shoot-em-up in the style of Raptor and Tyrian: fly up an alien
world, shoot what flies at you, and spend your score between levels on
weapons, accessory weapons and stronger hulls. It runs in 640 x 480 with
16-bit colour.

Status: see the pull request (stove build and lab).

## What is in the drawer

- `Rafkill`: the game.
- `data/`: the sprites, sounds, fonts, backgrounds and the eight levels;
  `music/`: the five XM songs. Upstream's own files as they are.
- `Libs/allegro4.library` and `Libs/acgame.library`: Allegro 4 for GFOS
  (gfopenallegro) on ACGame. The game opens them from its own `Libs/`.
- `User/`: your settings (`rafkill.config`) and saved games
  (`player1.rap` and on), made as you play. Updates and
  `GFOpenUpTool REMOVE` leave it alone.
- `Controls`, `ReadMe-Rafkill` (the author's read-me), `Licences.txt`,
  `COPYING.txt`.

## Playing

Run Install-Rafkill (or copy the Rafkill drawer where you want it), then
double-click Rafkill, or start it from a Shell from anywhere: the game
makes its own drawer its current directory while it runs. The keys are
in `Controls`.

## How the port is made

- The code is upstream's, built against gfopenallegro's Allegro 4 with
  68040 soft float (`amiga/Makefile.amigaos`). The game asks for 16-bit
  colour; gfopenallegro draws it in truecolour and shows it on ACGame's
  8-bit screen through a colour cube, so colours are coarser than on a
  truecolour screen until ACGame has one.
- The game's data is read from its own drawer (`PROGDIR:`), and its
  settings and saved games go in `User/` (`src/system.cpp`,
  `src/config.cpp`, `src/loadsave.cpp`, `src/defs.cpp`). The changes are
  each marked `__amigaos__`.
- Upstream plays its XM music with DUMB. GFOS has no DUMB library yet,
  and ACGame has no audio yet, so `amiga/music_silent.cpp` keeps the
  Music class (songs, play, pause, volume) and plays nothing; DUMB's
  set-up in `src/init.cpp` is left out. Sound effects are silent for now
  too: gfopenallegro plays samples once ACGame has audio.

## Building

    make -f amiga/Makefile.amigaos PREFIX=<stove>/prefix A4=<gfopenallegro>/allegro4 A4OUT=... ACGOUT=...

or, in Cradle, stove_build with the os32-gcc16-open6 stove and target
package (`package/build-amiga.sh`), which also builds allegro4.library
and acgame.library at the commits `package/package.env` pins, and packs
Rafkill-VERSION-68040.lha and the GFOpenUp part.

    tests/host/run.sh <gfopenallegro>/allegro4

runs the host tests: at 16-bit colour, all 226 sprites of
`data/raptor.dat` and the 12 sounds of `data/sound.dat` load with the
index and type their grabber headers give, `data/fonts.dat` loads, and
16-bit pixels read back as written; the silent Music class's volume
steps and limits; and the whole game links on the host against
gfopenallegro, so no Allegro or DUMB call is missing.

Designed, tested and delivered by The AmiCradle Team.
