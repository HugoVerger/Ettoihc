#include "../lib/inc/fmod.h"
#include "../lib/inc/fmod_errors.h"
#include "../lib/wincompat.h"
#include <stdio.h>


static void ERRCHECK(FMOD_RESULT result)
{
    if (result != FMOD_OK)
    {
        printf("FMOD error! (%d) %s\n", result, FMOD_ErrorString(result));
        exit(-1);
    }
}


void playSong (FMOD_SYSTEM *system, char *name)
{
    FMOD_SOUND       *sound;
    FMOD_RESULT       result;
    FMOD_CHANNEL     *channel = 0;
    
    result = FMOD_System_CreateSound(system, name, FMOD_CREATESTREAM, 0, &sound);
    ERRCHECK(result); //Cree un stream pour la musique
    ERRCHECK(FMOD_Sound_SetMode(sound, FMOD_LOOP_OFF));
    
    ERRCHECK(FMOD_System_PlaySound(system, FMOD_CHANNEL_FREE, sound, 0, &channel));
}


int main(int argc, char *argv[])
{
    FMOD_SYSTEM      *system;
    FMOD_RESULT       result;
    
    int               key;
    char             name[] = "media/wave.mp3";
    /*
        Create a System object and initialize.
    */
    ERRCHECK(FMOD_System_Create(&system));
    ERRCHECK(FMOD_System_Init(system, 32, FMOD_INIT_NORMAL, NULL));
    
    /*
        Main loop.
    */
    do
    {
        if (kbhit()) //Une des touches est utilisee
        {
            key = getch(); //Touche active

            /* On joue la musique */
            playSong(system, name);
        }

        FMOD_System_Update(system);
    } while (key != 27);

    // Fin du programme
    //result = FMOD_Sound_Release(sound);
    ERRCHECK(result);
    result = FMOD_System_Close(system);
    ERRCHECK(result);
    result = FMOD_System_Release(system);
    ERRCHECK(result);

    return 0;
}


