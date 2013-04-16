#include "lecture.h"

FMOD_CHANNEL      *channel;
float             spectum[512];

static void ERRCHECK(FMOD_RESULT problem)
{
  if (problem != FMOD_OK)
  {
    printf("FMOD error! (%d) %s\n", problem, FMOD_ErrorString(problem));
    exit(-1);
  }
}

// Create a System object and initialize.
FMOD_SYSTEM* initSystemSon(FMOD_SYSTEM *systemSong)
{
  ERRCHECK(FMOD_System_Create(&systemSong));
  ERRCHECK(FMOD_System_Init(systemSong, 1, FMOD_INIT_NORMAL, NULL));
  return systemSong;
}

//Joue la musique
FMOD_SOUND* playSong (FMOD_SYSTEM *systemSong, FMOD_SOUND *sound, char *name)
{     
  FMOD_CHANNELGROUP *channelg;
  int               etat;

  FMOD_System_GetMasterChannelGroup(systemSong, &channelg);
  FMOD_ChannelGroup_GetPaused(channelg, &etat);
  if (etat)
    pauseSong (systemSong);
  else
  {
    ERRCHECK(FMOD_System_CreateSound(systemSong, name,
                                     FMOD_CREATESTREAM, 0, &sound));
    ERRCHECK(FMOD_Sound_SetMode(sound, FMOD_LOOP_OFF));
    ERRCHECK(FMOD_System_PlaySound(systemSong, FMOD_CHANNEL_FREE, sound, 0, &channel));
  }

  return sound;
}

long getLength (FMOD_SOUND *sound)
{
  unsigned int lenms = 0;
  FMOD_Sound_GetLength(sound, &lenms, FMOD_TIMEUNIT_MS);
  return (long)lenms;
}

long getTime ()
{
  unsigned int ms = 0;
  FMOD_Channel_GetPosition(channel, &ms, FMOD_TIMEUNIT_MS);
  return (long)ms;
}

FMOD_CHANNEL* getChannel ()
{
  return channel;
}

void stopSong (FMOD_SYSTEM *systemSong)
{
  FMOD_CHANNELGROUP *channelg;
  FMOD_System_GetMasterChannelGroup(systemSong, &channelg);
  FMOD_ChannelGroup_Stop (channelg);
}

//Pause
void pauseSong (FMOD_SYSTEM *systemSong)
{ 
  FMOD_CHANNELGROUP *channelg;
  int               etat;

  FMOD_System_GetMasterChannelGroup(systemSong, &channelg);

  FMOD_ChannelGroup_GetPaused(channelg, &etat);
  FMOD_ChannelGroup_SetPaused(channelg, !etat);
}

//Augmente ou diminue le volume
void adjustVol (FMOD_SYSTEM *systemSong, float vol)
{
  FMOD_CHANNELGROUP *channelg;
  FMOD_System_GetMasterChannelGroup(systemSong, &channelg);
  FMOD_ChannelGroup_SetVolume(channelg, vol);
}

// Fin du programme
void destroySystem(FMOD_SYSTEM *systemSong, FMOD_SOUND *sound)
{
  FMOD_Sound_Release(sound);
  FMOD_System_Close(systemSong);
  FMOD_System_Release(systemSong);
}
