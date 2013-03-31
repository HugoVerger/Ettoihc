#include "lecture.h"

FMOD_SYSTEM 		*systemSong = NULL;
FMOD_SOUND 			*sound = NULL;
FMOD_CHANNELGROUP 	*channelg;
int					getpause = 0;

static void ERRCHECK(FMOD_RESULT problem)
{
    if (problem != FMOD_OK)
    {
        printf("FMOD error! (%d) %s\n", problem, FMOD_ErrorString(problem));
        exit(-1);
    }
}

// Create a System object and initialize.
void initSystemSon()
{
    ERRCHECK(FMOD_System_Create(&systemSong));
    ERRCHECK(FMOD_System_Init(systemSong, 1, FMOD_INIT_NORMAL, NULL));
}

//Joue la musique
void playSong (char *name)
{   
	if (!getpause)
	{
    	ERRCHECK(FMOD_System_CreateSound(systemSong, name, FMOD_CREATESTREAM, 0, &sound)); //Cree un stream pour la musique
    	ERRCHECK(FMOD_Sound_SetMode(sound, FMOD_LOOP_OFF));
    
    	ERRCHECK(FMOD_System_PlaySound(systemSong, FMOD_CHANNEL_FREE, sound, 0, &channel));
    }
    else
    {
    	pauseSong();
    }
}

void stopSong ()
{
	FMOD_System_GetMasterChannelGroup(systemSong, &channelg);
	FMOD_ChannelGroup_Stop (channelg);
}

//Pause
void pauseSong ()
{
    FMOD_BOOL etat;    
    FMOD_System_GetMasterChannelGroup(systemSong, &channelg);
    
    FMOD_ChannelGroup_GetPaused(channelg, &etat);
    FMOD_ChannelGroup_SetPaused(channelg, !etat);
    getpause = !getpause;
}

//Augmente ou diminue le volume
void adjustVol (float vol)
{
    FMOD_System_GetMasterChannelGroup(systemSong, &channelg);
    FMOD_ChannelGroup_SetVolume(channelg, vol);
}

// Fin du programme
void destroySystem()
{
    FMOD_Sound_Release(sound);
    FMOD_System_Close(systemSong);
    FMOD_System_Release(systemSong);
}
