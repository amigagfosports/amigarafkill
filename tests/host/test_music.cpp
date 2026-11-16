/* Rafkill for GFOS: host test of amiga/music_silent.cpp, the Music class
 * this build uses without DUMB: loading songs, play and pause, and the
 * volume steps and limits the menus use.
 * Copyright (c) 2026 AmiCradle Team. LGPL-2 or later, as Rafkill. */
#include "music.h"
#include <cstdio>
#include <cmath>

static int fails;
#define CHECK(c, m) do { if (!(c)) { fails++; std::printf("FAIL: %s\n", m); } } while (0)

int main(){
	CHECK( ! Music::loadSong( "music/song1.xm" ), "no Music object yet: nothing loads" );
	{
		Music m;
		CHECK( Music::loadSong( "music/song1.xm" ), "loadSong" );
		std::vector< std::string > songs( 1, "music/song2.xm" );
		Music::loadSong( songs );
		Music::setVolume( 0.5 );
		CHECK( std::fabs( Music::getVolume() - 0.5 ) < 1e-9, "setVolume" );
		Music::louden();
		CHECK( std::fabs( Music::getVolume() - 0.6 ) < 1e-9, "louden" );
		Music::soften(); Music::soften();
		CHECK( std::fabs( Music::getVolume() - 0.4 ) < 1e-9, "soften" );
		for ( int i = 0; i < 20; i++ ) Music::louden();
		CHECK( Music::getVolume() == 1.0, "volume stops at 1" );
		Music::mute();
		CHECK( Music::getVolume() == 0.0, "mute" );
		Music::soften();
		CHECK( Music::getVolume() == 0.0, "volume stops at 0" );
		Music::unmute();
		CHECK( Music::getVolume() == 1.0, "unmute" );
		Music::pause(); Music::play();
	}
	CHECK( ! Music::loadSong( "music/song1.xm" ), "after the Music object goes" );
	std::printf( fails ? "test_music: %d FAILED\n" : "test_music: PASS\n", fails );
	return fails != 0;
}
