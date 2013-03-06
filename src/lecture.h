#ifndef _LECTURE_H_
#define _LECTURE_H_

FMOD_SYSTEM* initSystemSon(FMOD_SYSTEM *system);

FMOD_SOUND* playSong (FMOD_SYSTEM *system, FMOD_CHANNEL *channel, char *name);

void pause (FMOD_SYSTEM *system);

void adjustVol (FMOD_SYSTEM *system, float vol);

void destroySystem(FMOD_SYSTEM *system, FMOD_SOUND *sound);

#endif
