external init_sound:	unit	-> unit 	= "ocaml_init"
external destroy_sound:	unit	-> unit 	= "ocaml_destroy"
external play_sound: 	string	-> unit 	= "ocaml_play"
external stop_sound: 	unit	-> unit 	= "ocaml_stop"
external vol_sound:  	float	-> unit 	= "ocaml_vol"
external pause_sound:	unit	-> unit 	= "ocaml_pause"
external spectre:		unit	-> unit 	= "ocaml_spectre"
external title_sound:	string	-> string	= "ocaml_titre"
external init_sdl:		unit	-> unit 	= "ocaml_initSDL"
external destroy_sdl:	unit	-> unit 	= "ocaml_destroySDL"

let _ =
	init_sound();
	init_sdl();
	play_sound("/home/manuel_c/Ettoihc/media/wave.mp3");
	spectre();
	destroy_sdl();
	destroy_sound()
