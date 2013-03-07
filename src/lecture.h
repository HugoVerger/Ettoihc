FMOD_SYSTEM* initSystemSon(FMOD_SYSTEM *system);

FMOD_SOUND* playSong (FMOD_SYSTEM *system, FMOD_CHANNEL *channel, char *name);

void pauseSong (FMOD_SYSTEM *system);

void adjustVol (FMOD_SYSTEM *system, float vol);

void destroySystem(FMOD_SYSTEM *system, FMOD_SOUND *sound);
