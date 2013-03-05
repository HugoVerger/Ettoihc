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
    FMOD_RESULT       result;
    
    ERRCHECK(FMOD_System_Create(&system));
    ERRCHECK(FMOD_System_Init(system, 32, FMOD_INIT_NORMAL, NULL));
    return system;
}

FMOD_SOUND* playSong (FMOD_SYSTEM *system, char *name)
{
    FMOD_CHANNEL     *channel = 0;    
    FMOD_RESULT       result;
    FMOD_SOUND       *sound;
    
    result = FMOD_System_CreateSound(system, name, FMOD_CREATESTREAM, 0, &sound);
    ERRCHECK(result); //Cree un stream pour la musique
    ERRCHECK(FMOD_Sound_SetMode(sound, FMOD_LOOP_OFF));
    
    ERRCHECK(FMOD_System_PlaySound(system, FMOD_CHANNEL_FREE, sound, 0, &channel));
    return sound;
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

int main()
{
    FMOD_SYSTEM *system = NULL;
    FMOD_SOUND  *sound = NULL;
    
    system = initSystemSon(system);
    char name[] = "media/wave.mp3";
    sound = playSong (system, name);
    
    destroySystem(system, sound);
    
    return 0;
}
