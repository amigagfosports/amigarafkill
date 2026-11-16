/* Rafkill for GFOS: the Music class without DUMB.
 * Upstream's src/music.cpp plays the XM songs with DUMB on a thread of
 * its own. GFOS has no DUMB library yet, and acgame.library has no audio
 * yet either, so this build keeps the class's interface and its volume and
 * plays nothing. src/music.cpp comes back when both are there.
 * Copyright (c) 2026 AmiCradle Team. LGPL-2 or later, as Rafkill. */
#include "music.h"
#include <string>
#include <vector>

using namespace std;

static Music * instance = NULL;
static double volume = 1.0;

Music::Music(): playing( false ), player( NULL ), music_file( NULL ){
	if ( instance == NULL ){
		instance = this;
	}
}

Music::~Music(){
	if ( instance == this ){
		instance = NULL;
	}
}

double Music::getVolume(){ return volume; }
void Music::doPlay(){}

bool Music::loadSong( const char * song ){
	return instance != NULL && instance->internal_loadSong( song );
}

bool Music::loadSong( const string & song ){
	return loadSong( song.c_str() );
}

void Music::loadSong( const vector< string > & songs ){
	if ( ! songs.empty() ){
		loadSong( songs.front() );
	}
}

void Music::_play(){ playing = true; }
void Music::_pause(){ playing = false; }
void Music::play(){ if ( instance ) instance->_play(); }
void Music::pause(){ if ( instance ) instance->_pause(); }

void Music::_soften(){ _setVolume( volume - 0.1 ); }
void Music::_louden(){ _setVolume( volume + 0.1 ); }
void Music::soften(){ if ( instance ) instance->_soften(); }
void Music::louden(){ if ( instance ) instance->_louden(); }

void Music::setVolume( double vol ){
	if ( instance ){
		instance->_setVolume( vol );
	} else {
		volume = vol;
	}
}

void Music::_setVolume( double vol ){
	if ( vol < 0 ) vol = 0;
	if ( vol > 1 ) vol = 1;
	volume = vol;
}

void Music::mute(){ setVolume( 0 ); }
void Music::unmute(){ setVolume( 1.0 ); }

bool Music::internal_loadSong( const char * path ){
	playing = path != NULL;
	return playing;
}
