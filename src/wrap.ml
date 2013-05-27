(*
  Fonctions C
*)
external soundDim:      float -> float -> float -> unit = "ocaml_3D"
external playlistSave:  string-> string -> unit = "ocaml_playlist"
external egaliseur:     float -> float  -> unit = "ocaml_egaliseur"
external biblioSave:    string-> unit   = "ocaml_biblio"
external init_sound:    unit  -> unit   = "ocaml_init"
external destroy_sound:	unit  -> unit   = "ocaml_destroy"
external play_sound:    string-> unit   = "ocaml_play"
external pause_sound:   unit  -> unit   = "ocaml_pause"
external length_sound:  unit  -> int    = "ocaml_length"
external time_sound:    unit  -> int    = "ocaml_time"
external setTime:       float -> unit   = "ocaml_setTime"
external stop_sound:    unit  -> unit   = "ocaml_stop"
external vol_sound:     float -> unit   = "ocaml_vol"
external dist_sound:    float -> unit   = "ocaml_distortion"
external echo_sound:    float -> unit   = "ocaml_echo"
external flange_sound:  unit  -> unit   = "ocaml_flange"
external chorus_sound:  unit  -> unit   = "ocaml_chorus"
external lpasse_sound:  unit  -> unit   = "ocaml_lpasse"
external hpasse_sound:  unit  -> unit   = "ocaml_hpasse"

external spectre_sound: float array -> unit = "ocaml_spectrum"
