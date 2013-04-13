#include "effects.h"

FMOD_DSP* distortion_event(FMOD_SYSTEM* system,FMOD_DSP* distortion, float quantity)
{
  FMOD_DSP_Remove(distortion);
  FMOD_System_CreateDSPByType(system,	FMOD_DSP_TYPE_DISTORTION,
                              &distortion);
  FMOD_System_AddDSP(system, distortion, 0);
  FMOD_DSP_SetParameter(distortion, FMOD_DSP_DISTORTION_LEVEL, quantity);
  return distortion;
}

FMOD_DSP* echo_event(FMOD_SYSTEM* system,FMOD_DSP* echo, float quantity)
{
  FMOD_DSP_Remove(echo);
  FMOD_System_CreateDSPByType(system, FMOD_DSP_TYPE_ECHO, &echo);
  FMOD_System_AddDSP(system, echo, 0);
  FMOD_DSP_SetParameter(echo, FMOD_DSP_ECHO_DELAY, quantity);
  return echo;
}

FMOD_DSP* flange_event(FMOD_SYSTEM* system,FMOD_DSP* flange)
{
	int active;
	FMOD_DSP_GetActive(flange, &active);
  	if (active)
    {
    	FMOD_DSP_Remove(flange);
    }
  	else 
    {
    	FMOD_System_CreateDSPByType(system, 
    							FMOD_DSP_TYPE_FLANGE, &flange);
    	FMOD_System_AddDSP(system,flange,0);
    }
    return flange;
}

FMOD_DSP* chorus_event(FMOD_SYSTEM* system,FMOD_DSP* chorus) 
{
  	int active;

  	FMOD_DSP_GetActive(chorus, &active);
  	if (active)
    {
      	FMOD_DSP_Remove(chorus);
    }
  	else
    {
    	FMOD_System_CreateDSPByType(system,
    							FMOD_DSP_TYPE_CHORUS, &chorus);
      	FMOD_System_AddDSP(system, chorus, 0);
    }
    return chorus;
}

FMOD_DSP* low_pass_event(FMOD_SYSTEM* system,FMOD_DSP* low_pass) 
{
  int active;

  	FMOD_DSP_GetActive(low_pass, &active);
  	if (active)
    {
      	FMOD_DSP_Remove(low_pass);
    }
  	else
    {
    	FMOD_System_CreateDSPByType(system, 
    							FMOD_DSP_TYPE_LOWPASS, &low_pass);
      FMOD_System_AddDSP(system, low_pass, 0);
    }
	return low_pass;
}

FMOD_DSP* high_pass_event(FMOD_SYSTEM* system,FMOD_DSP* high_pass) 
{
	int active;

 	FMOD_DSP_GetActive(high_pass, &active);
  	if (active)
    {
      	FMOD_DSP_Remove(high_pass);
    }
  	else
    {
    	FMOD_System_CreateDSPByType(system,
    							FMOD_DSP_TYPE_HIGHPASS, &high_pass);
     	FMOD_System_AddDSP(system, high_pass, 0);
    }
	return high_pass;
}

FMOD_DSP* rock (FMOD_SYSTEM* system, FMOD_DSP* dsp, float center, float gain)
{
  FMOD_DSP_Remove(dsp);

  FMOD_System_CreateDSPByType(system, FMOD_DSP_TYPE_PARAMEQ, &dsp);
  FMOD_DSP_SetParameter(dsp, FMOD_DSP_PARAMEQ_CENTER, center);
  FMOD_DSP_SetParameter(dsp, FMOD_DSP_PARAMEQ_GAIN, gain);
  FMOD_System_AddDSP(system, dsp, 0);

  return dsp;
}
