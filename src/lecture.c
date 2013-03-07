#include "../lib/inc/fmod.h"
#include "../lib/inc/fmod_errors.h"
#include "../lib/wincompat.h"
#include <stdio.h>

static void ERRCHECK(FMOD_RESULT problem)
{
    if (problem != FMOD_OK)
    {
        printf("FMOD error! (%d) %s\n", problem, FMOD_ErrorString(problem));
        exit(-1);
    }
}

// Create a System object and initialize.
FMOD_SYSTEM* initSystemSon(FMOD_SYSTEM *system)
{
    ERRCHECK(FMOD_System_Create(&system));
    ERRCHECK(FMOD_System_Init(system, 32, FMOD_INIT_NORMAL, NULL));
    return system;
}

//Joue la musique
FMOD_SOUND* playSong (FMOD_SYSTEM *system, FMOD_CHANNEL *channel, char *name)
{ 
    FMOD_RESULT       result;
    FMOD_SOUND       *sound;
    
    result = FMOD_System_CreateSound(system, name, FMOD_CREATESTREAM, 0, &sound);
    ERRCHECK(result); //Cree un stream pour la musique
    ERRCHECK(FMOD_Sound_SetMode(sound, FMOD_LOOP_OFF));
    
    ERRCHECK(FMOD_System_PlaySound(system, FMOD_CHANNEL_FREE, sound, 0, &channel));
    return sound;
}

//Pause
void pauseSong (FMOD_SYSTEM *system)
{
    FMOD_BOOL etat;
    FMOD_CHANNELGROUP *canal;
    
    FMOD_System_GetMasterChannelGroup(system, &canal);
    
    FMOD_ChannelGroup_GetPaused(canal, &etat);
    FMOD_ChannelGroup_SetPaused(canal, !etat);
}

//Augmente ou diminue le volume
void adjustVol (FMOD_SYSTEM *system, float vol)
{
    float volume;
    FMOD_CHANNELGROUP *canal;
    
    FMOD_System_GetMasterChannelGroup(system, &canal);

    FMOD_ChannelGroup_GetVolume(canal, &volume);
    volume += vol;
    FMOD_ChannelGroup_SetVolume(canal, volume);
}

// Fin du programme
void destroySystem(FMOD_SYSTEM *system, FMOD_SOUND *sound)
{    
    FMOD_RESULT       result;
    
    result = FMOD_Sound_Release(sound);
    ERRCHECK(result);
    result = FMOD_System_Close(system);
    ERRCHECK(result);
    result = FMOD_System_Release(system);
    ERRCHECK(result);
}
