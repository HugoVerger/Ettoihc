#include <caml/mlvalues.h>
#include "../lib/inc/fmod.h"
#include "../lib/inc/fmod_errors.h"
#include "../lib/wincompat.h"
#include <stdio.h>
#include "lecture.h"

CAMLprim value
prog (value unit)
{
    int key = ' ';
    
    while (key != 'q'){
    if (kbhit())
        {
            key = getch();

            switch (key)
            {
                case ' ' :
                {
                    pauseSong();
                    break;
                }
                case '-' :
                {
                    adjustVol(-0.05f);
                    break;
                }
                case '+' :
                {
                    adjustVol(0.05f);
                    break;
                }
            }
        }
    }
    
	return unit;
}
