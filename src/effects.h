#include <stdlib.h> 
#include <stdio.h>
#include "../fmod/inc/fmod.h"
#include "../fmod/inc/fmod_dsp.h"
#include "../fmod/inc/fmod_errors.h"

FMOD_DSP* distortion_event(FMOD_SYSTEM* system,FMOD_DSP* distortion, float f);

FMOD_DSP* echo_event(FMOD_SYSTEM* system,FMOD_DSP* echo, float f);

FMOD_DSP* flange_event(FMOD_SYSTEM* system,FMOD_DSP* flange);

FMOD_DSP* chorus_event(FMOD_SYSTEM* system,FMOD_DSP* chorus);

FMOD_DSP* parameq_event(FMOD_SYSTEM* system,FMOD_DSP* parameq);

FMOD_DSP* low_pass_event(FMOD_SYSTEM* system,FMOD_DSP* low_pass);

FMOD_DSP* high_pass_event(FMOD_SYSTEM* system,FMOD_DSP* high_pass);

FMOD_DSP* egaliseur (FMOD_SYSTEM* system, FMOD_DSP* dsp, float center, float gain);

void set3D (FMOD_SYSTEM* system, FMOD_VECTOR oldpos, FMOD_VECTOR pos);
