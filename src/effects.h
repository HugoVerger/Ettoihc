#include <stdlib.h> 
#include <stdio.h>
#include "../fmod/inc/fmod.h"

void distortion_event(FMOD_SYSTEM* system,FMOD_DSP* distortion);

void echo_event(FMOD_SYSTEM* system,FMOD_DSP* echo);

void flange_event(FMOD_SYSTEM* system,FMOD_DSP* flange);

void chorus_event(FMOD_SYSTEM* system,FMOD_DSP* chorus);

void parameq_event(FMOD_SYSTEM* system,FMOD_DSP* parameq);

void low_pass_event(FMOD_SYSTEM* system,FMOD_DSP* low_pass);

void high_pass_event(FMOD_SYSTEM* system,FMOD_DSP* high_pass);
