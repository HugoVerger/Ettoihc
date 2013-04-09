(*
  Fonctions C
*)
external playlistSave:  string-> string -> unit = "ocaml_playlist"
external distortion_sound:        unit	-> unit = "ocaml_distortion"
external biblioSave:    string-> unit   = "ocaml_biblio"
external init_sound:    unit	-> unit   = "ocaml_init"
external destroy_sound:	unit	-> unit   = "ocaml_destroy"
external play_sound: 	  string-> unit   = "ocaml_play"
external length_sound:  unit  -> int    = "ocaml_length"
external stop_sound:    unit	-> unit   = "ocaml_stop"
external vol_sound:     float	-> unit   = "ocaml_vol"
external pause_sound:   unit	-> unit   = "ocaml_pause"
external echo_sound:    unit	-> unit   = "ocaml_echo"
external flange_sound:  unit	-> unit   = "ocaml_flange"
external chorus_sound:  unit	-> unit   = "ocaml_chorus"
external amelio_sound:  unit	-> unit   = "ocaml_amelioration"
external lpasse_sound:  unit	-> unit   = "ocaml_lpasse"
external hpasse_sound:  unit	-> unit   = "ocaml_hpasse"
