/* Rafkill for GFOS: start-up bits.
 * The game's drawer (PROGDIR:) is the current directory while it runs, and
 * the Shell's comes back at exit; the player's settings and saved games go
 * in its User drawer (src/system.cpp, src/loadsave.cpp).
 * Copyright (c) 2026 AmiCradle Team. LGPL-2 or later, as Rafkill. */
#include <stdlib.h>
#include <sys/stat.h>
#include <proto/dos.h>

extern "C" {
unsigned long __stack = 512 * 1024;
}
static const char amiga_ver[] __attribute__((used)) =
  "$VER: Rafkill 1.2.4 (16.11.2026)";

static BPTR progdir_lock, old_dir;
static int dir_changed;

static void amiga_restore_dir(void)
{
    if (dir_changed) {
        CurrentDir(old_dir);
        UnLock(progdir_lock);
        dir_changed = 0;
    }
}

static void __attribute__((constructor)) amiga_enter_progdir(void)
{
    progdir_lock = Lock((CONST_STRPTR)"PROGDIR:", ACCESS_READ);
    if (progdir_lock) {
        old_dir = CurrentDir(progdir_lock);
        dir_changed = 1;
        atexit(amiga_restore_dir);
    }
    mkdir("User", 0755);
}
