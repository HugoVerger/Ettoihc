#include "effects.h"

void distortion_event(FMOD_SYSTEM* system,FMOD_DSP* distortion)
{
  int state;
  FMOD_DSP_GetActive(distortion, &state);
  if (state)
    {
      FMOD_DSP_Remove(distortion);
    }
  else
    {
      FMOD_System_AddDSP(system, distortion, 0);
      FMOD_DSP_SetParameter(distortion, FMOD_DSP_DISTORTION_LEVEL, 0.8f);
    }
}

void echo_event(FMOD_SYSTEM* system,FMOD_DSP* echo)
{
  int active;
  FMOD_DSP_GetActive(echo, &active);
  if (active)
  {
	FMOD_DSP_Remove(echo);
  }
  else
  {
	FMOD_System_AddDSP(system,echo,0);
	FMOD_DSP_SetParameter(echo, FMOD_DSP_ECHO_DELAY, 70.0f);
  }
}

void flange_event(FMOD_SYSTEM* system,FMOD_DSP* flange)
{
  int active;
  FMOD_DSP_GetActive(flange, &active);
  if (active)
    {
      FMOD_DSP_Remove(flange);
    }
  else 
    {
      FMOD_System_AddDSP(system,flange,0);
    }
}

void chorus_event(FMOD_SYSTEM* system,FMOD_DSP* chorus) 
{
  int active;

  FMOD_DSP_GetActive(chorus, &active);

  if (active)
    {
      FMOD_DSP_Remove(chorus);
    }
  else
    {
      FMOD_System_AddDSP(system, chorus, 0);
    }

}

void parameq_event(FMOD_SYSTEM* system,FMOD_DSP* parameq)
{
  int active;

  FMOD_DSP_GetActive(parameq, &active);

  if (active)
    {
      FMOD_DSP_Remove(parameq);
    }
  else
    {
      FMOD_System_AddDSP(system, parameq, 0);
      
      FMOD_DSP_SetParameter(parameq, FMOD_DSP_PARAMEQ_CENTER, 5000.0f);
      FMOD_DSP_SetParameter(parameq, FMOD_DSP_PARAMEQ_GAIN, 0.0f);
    }

}

void low_pass_event(FMOD_SYSTEM* system,FMOD_DSP* low_pass) 
{
  int active;

  FMOD_DSP_GetActive(low_pass, &active);

  if (active)
    {
      FMOD_DSP_Remove(low_pass);
    }
  else
    {
      FMOD_System_AddDSP(system, low_pass, 0);
    }

}

void high_pass_event(FMOD_SYSTEM* system,FMOD_DSP* high_pass) 
{
  int active;

  FMOD_DSP_GetActive(high_pass, &active);

  if (active)
    {
      FMOD_DSP_Remove(high_pass);
    }
  else
    {
      FMOD_System_AddDSP(system, high_pass, 0);
    }

}
