#include <stdlib.h> 
#include <stdio.h>
#include "../fmod/inc/fmod.h"
#include "../fmod/inc/fmod_errors.h"

FMOD_DSP* distortion_event(FMOD_SYSTEM* system,FMOD_DSP* distortion);

FMOD_DSP* echo_event(FMOD_SYSTEM* system,FMOD_DSP* echo);

FMOD_DSP* flange_event(FMOD_SYSTEM* system,FMOD_DSP* flange);

FMOD_DSP* chorus_event(FMOD_SYSTEM* system,FMOD_DSP* chorus);

FMOD_DSP* parameq_event(FMOD_SYSTEM* system,FMOD_DSP* parameq);

FMOD_DSP* low_pass_event(FMOD_SYSTEM* system,FMOD_DSP* low_pass);

FMOD_DSP* high_pass_event(FMOD_SYSTEM* system,FMOD_DSP* high_pass);
