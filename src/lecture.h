#ifndef _LECTURE_H_
#define _LECTURE_H_

FMOD_SYSTEM* initSystemSon(FMOD_SYSTEM *system);

FMOD_SOUND* playSong (char *name);

void destroySystem(FMOD_SYSTEM *system, FMOD_SOUND *sound);

#endif
