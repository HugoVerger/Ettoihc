(*
	Fonctions C
*)

external init_sound:	unit	-> unit = "ocaml_init"
external destroy_sound:	unit	-> unit = "ocaml_destroy"
external play_sound: 	string	-> unit = "ocaml_play"
external vol_sound:  	float	-> unit = "ocaml_vol"
external pause_sound:	unit	-> unit = "ocaml_pause"
external spectre:		unit	-> unit = "ocaml_spectre"
external init_sdl:	unit	-> unit = "ocaml_initSDL"
external destroy_sdl:	unit	-> unit = "ocaml_destroySDL"

(*
	Code OCamL
*)

(* Fenêtre principale *)

let window =
  ignore(GMain.init ());
  let wnd = GWindow.window
      ~title:"Ettoihc"
      ~position:`CENTER
      ~resizable:true
      ~width:600 
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
  ~width:360
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
 

(* Zone de texte *)

let text =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`ALWAYS 
    ~shadow_type:`ETCHED_IN
    ~height: 160
    ~packing:centerbox#add () in
  let txt = GText.view 
    ~packing:scroll#add ()
    ~editable: false  
  	~cursor_visible: false in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(* Bouton d'ouverture du fichier *) 

let filepath = ref ""
  
let str_op = function
  | Some x -> x
  | _ -> failwith "Need a file"
      
let music_filter = GFile.filter
  ~name:"Music File"
  ~patterns:["*.mp3"]()
  
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
    	(filepath := (str_op(dlg#filename));
    	text#buffer#set_text (!filepath));
    dlg#misc#hide ()));
 btn

let separator1 = ignore (GButton.separator_tool_item ~packing:toolbar#insert ())

(* Bouton Previous *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PREVIOUS
    ~label:"Previous"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> ()));
  btn

(* Bouton Play *)

let play filename =
  if filename = "" then failwith "Need a file"
  else text#buffer#set_text (!filepath)
 
let play_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PLAY
    ~label:"Play"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked 
  	(fun () -> 
  		play !filepath;
		play_sound("/home/manuel_c/Ettoihc/media/wave.mp3");
		spectre ()));
  btn

(* Bouton Pause *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PAUSE
    ~label:"Pause"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> pause_sound ()));
  btn

(* Bouton Next *)

let next_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_NEXT
    ~label:"Next"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> ()));
  btn

let separator2 = ignore (GButton.separator_tool_item ~packing:toolbar#insert ())


(* Bouton Volume *)

let file_vol = ref 50.0
let adj= GData.adjustment 
  ~value:50.0   ~lower:0.0 
  ~upper:110.0  ~step_incr:1. () 

let vol_change vol_b() =
  file_vol := vol_b#adjustment#value;
  vol_sound (!file_vol /. 100.)

let volume=
  let volume_button = GRange.scale `HORIZONTAL
    ~draw_value:true
    ~show:true
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
  ignore(btn#connect#clicked (fun () -> ignore (dlg#run ()); dlg#misc#hide ()));
  btn

let _ =
	init_sdl();
	init_sound();
	ignore(window#event#connect#delete confirm);
  	window#show ();
  	GMain.main ();
	destroy_sound();
	destroy_sdl()


(*http://www.linux-nantes.org/~fmonnier/ocaml/ocaml-wrapping-c.php#ref_custom*)
