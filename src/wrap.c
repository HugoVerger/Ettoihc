#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include "lecture.h"
#include "playlist.h"
#include "spectre.h"
#include "effects.h"

FMOD_SYSTEM     *systemSong = NULL;
FMOD_SOUND      *sound = NULL;
FMOD_DSP        *distortion = 0, *flange = 0, *echo = 0, *chorus = 0,
                *parameq = 0, *low_pass = 0, *high_pass = 0;
long            soundLength = 0;

value ocaml_play (value v)
{
  sound = playSong(systemSong, sound, String_val(v));
  return v;
}

value ocaml_length ()
{
  soundLength = getLength(sound);
  return Val_long(soundLength);
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
  return v;
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

value ocaml_biblio (value s)
{
  save_biblio(String_val(s));
  return Val_unit;
}

value ocaml_distortion (value v)
{
  distortion = distortion_event(systemSong, distortion);
  return v;
}

value ocaml_echo (value v)
{
  echo = echo_event(systemSong, echo);
  return v; 
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

value ocaml_amelioration (value v)
{
  parameq = parameq_event(systemSong, parameq);
  return v;
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
