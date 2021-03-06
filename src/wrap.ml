(*
  Fonctions C
*)
external egaliseur:     float -> float  -> unit = "ocaml_egaliseur"
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
external soundPan:      float -> unit   = "ocaml_pan"

external spectre_sound: float array -> unit = "ocaml_spectrum"
