#include <caml/mlvalues.h>
#include "lecture.h"
#include "playlist.h"
#include "spectre.h"
#include "effects.h"

FMOD_SYSTEM 		*systemSong = NULL;
FMOD_SOUND 			*sound = NULL;

value ocaml_play (value v)
{
  sound = playSong(systemSong, sound, String_val(v));
  return v;
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

value ocaml_distortion (value v)
{
  return v;
}

value ocaml_echo (value v)
{
  return v; 
}

value ocaml_flange(value v)
{
  return v;
}

value ocaml_chorus (value v)
{
  return v ;
}

value ocaml_amelioration (value v)
{
  return v;
}

value ocaml_lpass (value v)
{
  return v;
}

value ocaml_hpass (value v)
{
  return v;
}
