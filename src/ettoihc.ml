(*
	Fonctions C
*)
external playlistSave:	string 	-> string 	-> unit = "ocaml_playlist"
external init_sound:	unit	-> unit 	= "ocaml_init"
external destroy_sound:	unit	-> unit 	= "ocaml_destroy"
external play_sound: 	string	-> unit 	= "ocaml_play"
external stop_sound: 	unit	-> unit 	= "ocaml_stop"
external vol_sound:  	float	-> unit 	= "ocaml_vol"
external pause_sound:	unit	-> unit 	= "ocaml_pause"
external spectre:		unit	-> unit 	= "ocaml_spectre"
external init_sdl:		unit	-> unit 	= "ocaml_initSDL"
external destroy_sdl:	unit	-> unit 	= "ocaml_destroySDL"

(* Declarations variables *)

let filepath = ref ""
let filedisplay = ref ""
let allFile = ref ""
let playList = ref ""
let listFile = ref []
let indexSong = ref 0
let pause = ref true

(*
//
//		Structure interface
//
*)

(* Fenêtre principale *)

let window =
  ignore(GMain.init ());
  let wnd = GWindow.window
      ~title:"Ettoihc"
      ~position:`CENTER
      ~resizable:true
      ~width:660 
      ~height:400 () in
  ignore(wnd#connect#destroy GMain.quit);
  wnd

(* Fenêtre de confirmation de sortie *)

let confirm _ =
  let dlg = GWindow.message_dialog
    ~message:"<b><big>Voulez-vous vraiment quitter ?</big></b>\n"
    ~parent:window
    ~destroy_with_parent:true
    ~use_markup:true
    ~message_type:`QUESTION
    ~position:`CENTER_ON_PARENT
    ~buttons:GWindow.Buttons.yes_no () in
  let res = dlg#run () = `NO in
  dlg#destroy ();
  res


(* Boites de la fenêtre principale *)

let mainbox = 
	let box = GPack.vbox
  		~border_width:10
  		~packing:window#add () in
  	box#set_homogeneous false;
  	box

let menubox = 
	let box = GPack.hbox
  		~height: 60
  		~packing:(mainbox#pack ~expand:false) () in
  	box#set_homogeneous false;
  	box
  
let toolbar = GButton.toolbar  
  ~orientation:`HORIZONTAL  
  ~style:`BOTH
  ~width:490
  ~height:10
  ~packing:(menubox#pack ~expand:false) ()

let volbox = GPack.hbox
  ~width: 90
  ~packing:(menubox#pack ~expand:false) ()
  
let infobar = GButton.toolbar  
  ~orientation:`HORIZONTAL  
  ~style:`BOTH
  ~width:60
  ~packing:(menubox#pack ~expand:false) ()

let centerbox = 
	let box = GPack.hbox
  		~height: 20
  		~packing:(mainbox#pack ~expand:false) () in
  	box#set_homogeneous false;
  	box
  	
let playlistbox =
	let win = GBin.viewport
  		~height: 20
  		~packing:(mainbox#pack ~expand:true) () in
  	win
 
(* Zone de texte *)

let text =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing:centerbox#add () in
  let txt = GText.view 
    ~packing:scroll#add ()
    ~editable: false  
  	~cursor_visible: false in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(* Zone d'effet *)

let playlist =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing:playlistbox#add () in
  let txt = GText.view 
    ~packing:scroll#add ()
    ~editable: false  
  	~cursor_visible: false in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(*
//
//		Declaration boutons
//
*)


(* Declaration fonctions *)

let str_op = function
	| Some x -> x
	| _ -> failwith "Need a file"

let play () = 
		Playlist.actDisplay !filepath filedisplay;
		text#buffer#set_text (!filedisplay);
		play_sound(!filepath)

let precedent = (fun () ->
	(if (!indexSong != 0) then
  		begin
  			indexSong := !indexSong - 1;
  			filepath := List.nth !listFile !indexSong;
  			Playlist.actDisplay !filepath filedisplay;
  			play ()
  		end
  	else
  		(if (!filedisplay != "") then
  			begin
  			filepath := "";
  			filedisplay := "";
  			indexSong := 0;
  			stop_sound()
  			end
  		)
  	);
  	text#buffer#set_text (!filedisplay))
  	
let suivant = (fun () ->
	(if (!indexSong != List.length !listFile - 1) then
  		begin
  			indexSong := !indexSong + 1;
  			filepath := List.nth !listFile !indexSong;
  			Playlist.actDisplay !filepath filedisplay;
  			play ()
  		end
  	else
  		(if (!filedisplay != "") then
  			begin
  			filepath := "";
  			filedisplay := "";
  			indexSong := 0;
  			stop_sound()
  			end
  		)
  	);
  	text#buffer#set_text (!filedisplay))


(* Bouton d'ouverture du fichier *) 

let music_filter = GFile.filter
  ~name:"Music File"
  ~patterns:(["*.mp3";"*.m3u"]) ()
  
let open_button =
  let dlg = GWindow.file_chooser_dialog
    ~action:`OPEN
    ~parent:window
    ~position:`CENTER_ON_PARENT
    ~title: "Chargement d'une musique"
    ~destroy_with_parent:true () in
    dlg#set_filter music_filter;
    dlg#add_button_stock `CANCEL `CANCEL;
    dlg#add_select_button_stock `OPEN `OPEN;
 let btn = GButton.tool_button 
    ~stock:`OPEN
    ~packing:toolbar#insert () in 
 	ignore(btn#connect#clicked (fun () ->
    	if dlg#run () = `OPEN then 
    		begin
    		filepath := str_op(dlg#filename);
    		(if (Playlist.get_extension !filepath) then
    			Playlist.addSong !filepath filedisplay allFile
    							 playList listFile
    		else
    			(Playlist.cleanPlaylist filedisplay allFile playList
    									listFile indexSong pause;
    			stop_sound();
    			text#buffer#set_text "";
    			Playlist.addPlaylist !filepath filedisplay allFile
    								 playList listFile));
    		playlist#buffer#set_text (!allFile)
    		end;
    dlg#misc#hide ()));
 btn

(* Bouton Save *)

let save_button =
	let dlg = GWindow.file_chooser_dialog
		~action:`SAVE
		~parent:window
		~position:`CENTER_ON_PARENT
		~title:"Sauvegarde de la playlist"
		~destroy_with_parent:true () in
	dlg#add_button_stock `CANCEL `CANCEL;
	dlg#add_select_button_stock `SAVE `SAVE;
	let btn = GButton.tool_button
		~stock: `SAVE
		~packing: toolbar#insert () in
	ignore(btn#connect#clicked (fun () ->
	    if  (dlg#run () == `SAVE) then 
			(playlistSave (str_op(dlg#filename)) !playList);
	dlg#misc#hide ()));
	btn

let separator1 = 
	ignore (GButton.separator_tool_item ~packing:toolbar#insert ())

(* Bouton Previous *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PREVIOUS
    ~label:"Previous"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> precedent ()));
  btn

(* Bouton Play *)
 
let play_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PLAY
    ~label:"Play"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked 
  	(fun () ->
  		if (List.length !listFile != 0 && 
  		(!pause || (!filepath != List.nth !listFile !indexSong))) then
  			(filepath := List.nth !listFile !indexSong;
    		text#buffer#set_text (!filedisplay);
    		play ();
    		pause := false)));
  btn

(* Bouton Pause *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PAUSE
    ~label:"Pause"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> pause := true; pause_sound ()));
  btn

(* Bouton Stop *)

let stop_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_STOP
    ~label:"Stop"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> 
  			filepath := "";
  			filedisplay := "";
  			indexSong := 0;
  			stop_sound();
    		text#buffer#set_text (!filedisplay)));
  btn

(* Bouton Next *)

let next_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_NEXT
    ~label:"Next"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> suivant ()));
  btn

let separator2 = GButton.separator_tool_item ~packing:toolbar#insert ()


(* Bouton Volume *)

let file_vol = ref 50.
let adj= GData.adjustment 
  ~value:50.  ~lower:0.
  ~upper:110.  ~step_incr:1. () 

let vol_change vol_b() =
  file_vol := vol_b#adjustment#value;
  vol_sound (!file_vol /. 100.)

let volume=
  let volume_button = GRange.scale `HORIZONTAL
    ~draw_value:true
    ~show:true
    ~digits: 0
    ~adjustment:adj
    ~packing:volbox#add () in 
  ignore(volume_button#connect#value_changed (vol_change (volume_button)));
  volume_button

(* Bouton "A propos" *)

let about_button =
	let dlg = GWindow.about_dialog
		~authors:["Nablah"]
		~version:"1.0"
		~website:"http://ettoihc.wordpress.com/"
		~website_label:"Ettoihc Website"
		~position:`CENTER_ON_PARENT
		~parent:window
		~width: 400
		~height: 150
		~destroy_with_parent:true () in
	let btn = GButton.tool_button 
		~stock:`ABOUT 
		~packing:infobar#insert () in
	ignore(btn#connect#clicked (fun () -> 
		ignore (dlg#run ()); dlg#misc#hide ()));
	btn



let _ =
	init_sound();
	ignore(window#event#connect#delete confirm);
  	window#show ();
  	GMain.main ();
	destroy_sound()

(*http://www.linux-nantes.org/~fmonnier/ocaml/ocaml-wrapping-c.php#ref_custom*)
