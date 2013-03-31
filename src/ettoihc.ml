(*
  Fonctions C
*)
external playlistSave:	string 	-> string 	-> unit = "ocaml_playlist"
external biblioSave:	string 	-> unit		= "ocaml_biblio"
external init_sound:	unit	-> unit 	= "ocaml_init"
external destroy_sound:	unit	-> unit 	= "ocaml_destroy"
external play_sound: 	string	-> unit 	= "ocaml_play"
external stop_sound: 	unit	-> unit 	= "ocaml_stop"
external vol_sound:  	float	-> unit 	= "ocaml_vol"
external pause_sound:	unit	-> unit 	= "ocaml_pause"
external distortion_sound: unit	-> unit 	= "ocaml_distortion"
external echo_sound:	unit	-> unit 	= "ocaml_echo"
external flange_sound:	unit	-> unit 	= "ocaml_flange"
external chorus_sound: 	unit	-> unit 	= "ocaml_chorus"
external amelio_sound:	unit	-> unit 	= "ocaml_amelioration"
external lpasse_sound:	unit	-> unit 	= "ocaml_lpasse"
external hpasse_sound:	unit	-> unit 	= "ocaml_hpasse"

(* Declarations variables *)

let pause = ref true			(*Son en Cours*)
let filepath = ref ""
let indexSong = ref 0
let filedisplay = ref ""

let playListForDisplay = ref ""	(*Playlist en Cours*)
let playListForSave = ref ""
let playListFile = ref []

let biblioForDisplay = ref ""	(*Bibliotheque*)
let biblioForSave = ref ""
let biblioFile = ref [""]

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
    ~height:420 () in
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
  biblioSave !biblioForSave;
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
    

let notebook =GPack.notebook
  ~packing: mainbox#add()
  
let page1box = GPack.hbox ()
let ajout_tab1 =
  let name1 = GMisc.label
    ~text:"En cours" () in
  notebook#insert_page 
    ~tab_label:name1#coerce page1box#coerce

let page2box = GPack.vbox ()
let ajout_tab2 =
  let name1 = GMisc.label
    ~text:"Bibliotheque" () in
  notebook#insert_page 
    ~tab_label:name1#coerce page2box#coerce

let page3box = GPack.vbox ()
let ajout_tab3 =
  let name1 = GMisc.label
    ~text:"Effets" () in
  notebook#insert_page 
    ~tab_label:name1#coerce page3box#coerce 

let mixPage = GPack.vbox
  ~packing:page3box#add()

let mixFrame1 =GBin.frame
  ~width:800
  ~height:250
  ~border_width:0
  ~packing:mixPage#add ()

let mixFrame2 =GBin.frame
  ~width:800
  ~height:250
  ~border_width:0
  ~packing:mixPage#add ()
  
let firstLine =GPack.button_box `HORIZONTAL
  	~layout:`SPREAD
  	~packing:mixFrame1#add()
let secondLine =GPack.button_box `HORIZONTAL
  ~layout:`SPREAD
  ~packing:mixFrame2#add()
  
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

(* Zone de texte *)

let biblioText =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing:page2box#add () in
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
    ~packing:page1box#add () in
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
  	filepath := List.nth !playListFile !indexSong;
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
  (if (!indexSong != List.length !playListFile - 1) then
      begin
  	indexSong := !indexSong + 1;
  	filepath := List.nth !playListFile !indexSong;
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

let checkBiblio () =
	let rec noExist = function
		|[] -> true
		|h::t when h == !filepath -> false
		|_::t -> noExist t in
	if (noExist !biblioFile) then
		begin
			biblioFile := !biblioFile @ [!filepath];
			biblioForSave := !biblioForSave ^ !filepath ^ "\n";
			if Meta.Id3v1.has_tag !filepath then
				let t = Meta.Id3v1.read_file !filepath in
				biblioForDisplay := !biblioForDisplay ^
									Meta.Id3v1.getTitle t ^ 
									" - " ^ Meta.Id3v1.getArtist t ^ "\n"
			else
				biblioForDisplay := !filepath
		end
	

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
    	checkBiblio();
    	(if (Playlist.get_extension !filepath) then
    	    Playlist.addSong !filepath filedisplay playListForDisplay
    	      playListForSave playListFile
    	 else
    	    (Playlist.cleanPlaylist filedisplay playListForDisplay
    	       playListForSave	playListFile indexSong 
    	       pause;
    	     stop_sound();
    	     text#buffer#set_text "";
    	     Playlist.addPlaylist !filepath filedisplay playListForDisplay
    	       					playListForSave playListFile));
    	playlist#buffer#set_text (!playListForDisplay);
    	biblioText#buffer#set_text (!biblioForDisplay)
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
      (playlistSave (str_op(dlg#filename)) !playListForSave);
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
  		if (List.length !playListFile != 0 && 
  		(!pause || (!filepath != List.nth !playListFile !indexSong))) then
  			(filepath := List.nth !playListFile !indexSong;
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

let distortion =
  let dbut = GButton.button
    ~show:true
    ~label:"Distorsion"
    ~relief:`NORMAL
    ~packing:firstLine#add() in
  ignore(dbut#connect#clicked ~callback:distortion_sound);
  dbut

let amelioration =
  let abut = GButton.button
    ~show:true
    ~label:"Amélioration du son"
    ~relief:`NORMAL
    ~packing:firstLine#add() in
  ignore(abut#connect#clicked ~callback:amelio_sound);
  abut

let flange=
  let fbut = GButton.button
    ~show:true
    ~label:"Flange"
    ~relief:`NORMAL
    ~packing:firstLine#add() in
  ignore(fbut#connect#clicked ~callback:flange_sound);
  fbut

let chorus =
  let cbut = GButton.button
    ~show:true
    ~label:"Chorus"
    ~relief:`NORMAL
    ~packing:secondLine#add() in
  ignore(cbut#connect#clicked ~callback:chorus_sound);
  cbut

let echo =
  let ebut = GButton.button
    ~show:true
    ~label:"Echo"
    ~relief:`NORMAL
    ~packing:secondLine#add() in
  ignore(ebut#connect#clicked ~callback:echo_sound);
  ebut

let lowpass=
  let lbut = GButton.button
    ~show:true
    ~label:"Low Pass"
    ~relief:`NORMAL
    ~packing:secondLine#add() in
  ignore(lbut#connect#clicked ~callback:lpasse_sound);
  lbut

let highpass=
  let hbut = GButton.button
    ~show:true
    ~label:"High Pass"
    ~relief:`NORMAL
    ~packing:secondLine#add() in
  ignore(hbut#connect#clicked ~callback:hpasse_sound);
  hbut


let _ =
  init_sound();
  ignore(window#event#connect#delete confirm);
  Playlist.loadBiblio biblioForDisplay biblioForSave biblioFile;
  biblioText#buffer#set_text (!biblioForDisplay);
  window#show ();
  GMain.main ();
  destroy_sound()
