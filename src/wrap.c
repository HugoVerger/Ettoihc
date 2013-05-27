#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <SDL.h> 
#include "lecture.h"
#include "playlist.h"
#include "spectre.h"
#include "effects.h"

FMOD_SYSTEM     *systemSong = NULL;
FMOD_SOUND      *sound = NULL;
FMOD_DSP        *distortion = 0, *flange = 0, *echo = 0, *chorus = 0,
                *parameq = 0, *low_pass = 0, *high_pass = 0, *dsp0 = 0,
                *dsp1 = 0, *dsp2 = 0, *dsp3 = 0, *dsp4 = 0, *dsp5 = 0,
                *dsp6 = 0, *dsp7 = 0, *dsp8 = 0, *dsp9 = 0;
FMOD_VECTOR      listenerpos  = { 0.0f, 0.0f, 0.0f }; 
float           *spectre;

value ocaml_play (value v)
{
  sound = playSong(systemSong, sound, String_val(v));
  return v;
}

value ocaml_length ()
{
  return Val_long(getLength(sound));
}

value ocaml_time ()
{
  return Val_long(getTime());
}

value ocaml_setTime (value v)
{
  setTime(sound, Double_val (v));
  return Val_unit;
}

value ocaml_pause (value v)
{
  pauseSong(systemSong);
  return v;
}

value ocaml_stop (value v)
{
  stopSong(systemSong);
  return v;
}

value ocaml_vol (value v)
{
  adjustVol(systemSong, Double_val(v));
  return Val_unit;
}

value ocaml_destroy (value v)
{
  destroySystem(systemSong, sound);
  return v;
}

value ocaml_init (value v)
{
  systemSong = initSystemSon(systemSong);
  return v;
}

value ocaml_playlist (value n,value s)
{
  create_pl(String_val(n),String_val(s));
  return Val_unit;
}

value ocaml_distortion (value v)
{
  distortion = distortion_event(systemSong, distortion, Double_val(v));
  return Val_unit;
}

value ocaml_echo (value v)
{
  echo = echo_event(systemSong, echo, Double_val(v));
  return Val_unit;
}

value ocaml_flange(value v)
{
  flange = flange_event(systemSong, flange);
  return v;
}

value ocaml_chorus (value v)
{
  chorus = chorus_event(systemSong, chorus);
  return v ;
}

value ocaml_pan (value a)
{
  int t = (int)Double_val(a);
  setPan (getChannel(), t);
  return Val_unit;
}

value ocaml_egaliseur (value f, value g)
{
  int tmp = (int)Double_val(f);
  float gain = Double_val(g) / 100;
  switch (tmp) 
  {
    case 29 : dsp0 = egaliseur(systemSong, dsp0, 29., gain); break;
    case 59 : dsp1 = egaliseur(systemSong, dsp1, 59., gain); break;
    case 119 : dsp2 = egaliseur(systemSong, dsp2, 119., gain); break;
    case 237 : dsp3 = egaliseur(systemSong, dsp3, 237., gain); break;
    case 474 : dsp4 = egaliseur(systemSong, dsp4, 474., gain); break;
    case 947 : dsp5 = egaliseur(systemSong, dsp5, 947., gain); break;
    case 2000 : dsp6 = egaliseur(systemSong, dsp6, 2000., gain); break;
    case 4000 : dsp7 = egaliseur(systemSong, dsp7, 4000., gain); break;
    case 8000 : dsp8 = egaliseur(systemSong, dsp8, 8000., gain); break;
    case 15000 : dsp9 = egaliseur(systemSong, dsp9, 15000., gain); break;
    default : break;
  }
  return Val_unit;
}

value ocaml_lpasse (value v)
{
  low_pass = low_pass_event(systemSong, low_pass);
  return v;
}

value ocaml_hpasse (value v)
{
  high_pass = high_pass_event(systemSong, high_pass);
  return v;
}

value ocaml_spectre (value v)
{
  draw(getChannel());
  return v;
}

value ocaml_destroySDL (value v)
{
  destroySDL();
  return v;
}

value ocaml_initSDL (value v)
{
  initSDL();
  return v;
}

void spectreSong (float spectum[512])
{
  FMOD_CHANNEL* channel;
  
  channel = getChannel ();
  
  FMOD_Channel_GetSpectrum(channel, spectum, 512, 0,
                          FMOD_DSP_FFT_WINDOW_RECT);
}

value ocaml_spectrum (value float_array)
{
  float spectre[512];
  
  spectreSong(spectre);

  for (int i = 0; i < 512; i++)
  {
    Store_double_field(float_array, i, spectre[i]);
  }
  return Val_unit;
}
