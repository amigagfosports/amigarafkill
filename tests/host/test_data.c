/* Rafkill for GFOS: host test of the game's data, at the game's depth.
 * With set_color_depth(16), as src/init.cpp asks, data/raptor.dat and
 * data/sound.dat load through gfopenallegro's allegro4 reader with every
 * object at the index and type its grabber header gives (bitmaps as 16-bit
 * bitmaps), and data/fonts.dat loads; makecol16 and _getpixel16 read back
 * what _putpixel16 wrote, as src/bitmap.cpp uses them.
 * Copyright (c) 2026 AmiCradle Team. LGPL-2 or later, as Rafkill. */
#include <stdio.h>
#include <string.h>
#include "allegro.h"

static int fails;
#define CHECK(c, ...) do { if (!(c)) { fails++; printf("FAIL: "); printf(__VA_ARGS__); printf("\n"); } } while (0)

static int type_of(const char *t)
{
    if (!strcmp(t, "BMP")) return DAT_BITMAP;
    if (!strcmp(t, "SAMP")) return DAT_SAMPLE;
    if (!strcmp(t, "PAL")) return DAT_PALETTE;
    if (!strcmp(t, "FONT")) return DAT_FONT;
    if (!strcmp(t, "DATA")) return DAT_DATA;
    if (!strcmp(t, "RLE")) return DAT_RLE_SPRITE;
    return -1;
}

static int count_objects(DATAFILE *df)
{
    int n = 0;
    while (df[n].type != DAT_END) n++;
    if (n > 0 && df[n - 1].type == DAT_ID('i','n','f','o')) n--;   /* the grabber's own settings */
    return n;
}

static int check(const char *dir, const char *base)
{
    char path[512], line[256], sym[96], type[16];
    int idx, n = 0, count, b16 = 0;
    FILE *h;
    DATAFILE *df;
    snprintf(path, sizeof path, "%s/%s.h", dir, base);
    h = fopen(path, "r");
    snprintf(path, sizeof path, "%s/%s.dat", dir, base);
    df = load_datafile(path);
    CHECK(h && df, "%s: header or datafile missing", base);
    if (!h || !df) return 0;
    count = count_objects(df);
    while (fgets(line, sizeof line, h)) {
        if (sscanf(line, " #define %95s %d /* %15s */", sym, &idx, type) != 3) continue;
        CHECK(idx < count, "%s %s: index %d past %d", base, sym, idx, count);
        if (idx >= count) continue;
        CHECK(df[idx].type == type_of(type), "%s #%d %s: type %08x, header %s", base, idx, sym, df[idx].type, type);
        if (df[idx].type == DAT_BITMAP) {
            BITMAP *b = df[idx].dat;
            CHECK(b && b->w > 0 && b->h > 0, "%s %s: bad bitmap", base, sym);
            if (b && bitmap_color_depth(b) == 16) b16++;
        }
        n++;
    }
    fclose(h);
    CHECK(n == count, "%s: header lists %d, file has %d", base, n, count);
    printf("%s.dat: %d objects, %d bitmaps at 16-bit\n", base, n, b16);
    unload_datafile(df);
    return n;
}

int main(int argc, char **argv)
{
    const char *dir = argc > 1 ? argv[1] : "data";
    char path[512];
    DATAFILE *fonts;
    BITMAP *b;
    int c;
    CHECK(allegro_init() == 0, "allegro_init");
    set_color_depth(16);
    CHECK(check(dir, "raptor") == 226, "raptor.dat count");
    CHECK(check(dir, "sound") == 12, "sound.dat count");
    snprintf(path, sizeof path, "%s/fonts.dat", dir);
    fonts = load_datafile(path);
    CHECK(fonts && count_objects(fonts) > 0, "fonts.dat");
    if (fonts) {
        printf("fonts.dat: %d objects\n", count_objects(fonts));
        unload_datafile(fonts);
    }
    b = create_bitmap(8, 8);
    CHECK(b && bitmap_color_depth(b) == 16, "create_bitmap at 16-bit");
    if (b) {
        c = makecol16(240, 100, 0);
        _putpixel16(b, 3, 4, c);
        CHECK(_getpixel16(b, 3, 4) == c, "_getpixel16 reads what _putpixel16 wrote");
        CHECK(getr16(c) >= 232 && getg16(c) >= 96 && getb16(c) <= 8, "makecol16 colour");
        destroy_bitmap(b);
    }
    allegro_exit();
    printf(fails ? "test_data: %d FAILED\n" : "test_data: PASS\n", fails);
    return fails != 0;
}
