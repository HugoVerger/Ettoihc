#include "../fmod/inc/fmod.h"
#include "../fmod/inc/fmod_errors.h"
#include "../fmod/wincompat.h"
#include <stdio.h>

#ifndef _LECTURE_H_
#define _LECTURE_H_

FMOD_SYSTEM* initSystemSon(FMOD_SYSTEM *systemSong);

FMOD_SOUND* playSong (FMOD_SYSTEM *systemSong, FMOD_SOUND *sound, char *name);

long getLength(FMOD_SOUND *sound);

long getTime();

FMOD_CHANNEL* getChannel();

void pauseSong (FMOD_SYSTEM *systemSong);

void stopSong (FMOD_SYSTEM *systemSong);

void adjustVol (FMOD_SYSTEM *systemSong, float vol);

void destroySystem(FMOD_SYSTEM *systemSong, FMOD_SOUND *sound);

#endif
