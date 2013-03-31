#include "../fmod/inc/fmod.h"
#include "../fmod/inc/fmod_errors.h"
#include "../fmod/wincompat.h"
#include <stdio.h>

#ifndef _LECTURE_H_
#define _LECTURE_H_

FMOD_CHANNEL 		*channel;

void initSystemSon();

void playSong (char *name);

void pauseSong ();

void stopSong ();

void adjustVol (float vol);

void destroySystem();

#endif
