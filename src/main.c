#include "../lib/inc/fmod.h"
#include "../lib/inc/fmod_errors.h"
#include "../lib/wincompat.h"
#include <stdio.h>
#include <caml/mlvalues.h>

CAMLprim value
prog (value unit)
{
    FMOD_SYSTEM     *system = NULL;
    FMOD_SOUND      *sound = NULL;
    FMOD_CHANNEL    *channel = 0;
    int             key = ' ';
    
    system = initSystemSon(system);
    char name[] = "/home/manuel_c/Ettoihc/media/wave.mp3";
    sound = playSong(system, channel, name);
    
    while (key != 'q'){
    if (kbhit())
        {
            key = getch();

            switch (key)
            {
                case ' ' :
                {
                    pauseSong(system);
                    break;
                }
                case '-' :
                {
                    adjustVol(system, -0.05f);
                    break;
                }
                case '+' :
                {
                    adjustVol(system, 0.05f);
                    break;
                }
            }
        }
        
        FMOD_System_Update(system);
    }
    
    destroySystem(system, sound);
    
	return unit;
}
