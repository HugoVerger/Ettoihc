#include <caml/mlvalues.h>
#include "../lib/inc/fmod.h"
#include "../lib/inc/fmod_errors.h"
#include "../lib/wincompat.h"
#include <stdio.h>

FMOD_SYSTEM 		*systemSong;
FMOD_SOUND 			*sound = NULL;
FMOD_CHANNELGROUP 	*channelg;
FMOD_CHANNEL 		*channel;

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
    ERRCHECK(FMOD_System_Init(systemSong, 32, FMOD_INIT_NORMAL, NULL));
}

//Joue la musique
void playSong (char *name)
{     
    ERRCHECK(FMOD_System_CreateSound(systemSong, name, FMOD_CREATESTREAM, 0, &sound)); //Cree un stream pour la musique
    ERRCHECK(FMOD_Sound_SetMode(sound, FMOD_LOOP_OFF));
    
    ERRCHECK(FMOD_System_PlaySound(systemSong, FMOD_CHANNEL_FREE, sound, 0, &channel));
}

//Pause
void pauseSong ()
{
    FMOD_BOOL etat;
    FMOD_CHANNELGROUP *canal;
    
    FMOD_System_GetMasterChannelGroup(systemSong, &canal);
    
    FMOD_ChannelGroup_GetPaused(canal, &etat);
    FMOD_ChannelGroup_SetPaused(canal, !etat);
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
    FMOD_RESULT       result;
    
    result = FMOD_Sound_Release(sound);
    result = FMOD_System_Close(systemSong);
    ERRCHECK(result);
    result = FMOD_System_Release(systemSong);
    ERRCHECK(result);
}

//Lien C - OCamL

value ocaml_pause (value v)
{
  pauseSong();
  return v;
}

value ocaml_play (value v)
{
  playSong(String_val(v));
  return v;
}
  
value ocaml_vol (value v)
{
  adjustVol(Double_val(v));
  return v;
}
  
value ocaml_destroy (value v)
{
  destroySystem();
  return v;
}

value ocaml_init (value v)
{
  initSystemSon();
  return v;
}
