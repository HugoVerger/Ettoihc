(*
	Fonctions C
*)

external bobette: 		unit -> unit = "prog"
external init_sound:	unit	-> unit = "ocaml_init"
external destroy_sound:	unit	-> unit = "ocaml_destroy"
external play_sound: 	string	-> unit = "ocaml_play"
external vol_sound:  	float	-> unit = "ocaml_volume"
external pause_sound:	unit	-> unit = "ocaml_pause"

(*
	Code OCamL
*)

let _ =
	init_sound();
	play_sound("/home/manuel_c/Ettoihc/media/wave.mp3");
	bobette ();
	destroy_sound()


(*http://www.linux-nantes.org/~fmonnier/ocaml/ocaml-wrapping-c.php#ref_custom*)
