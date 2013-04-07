let filedisplay = ref ""

let toolbar = GButton.toolbar  
	~orientation:`HORIZONTAL  
	~style:`BOTH
	~width:470
	~height:10
	~packing:(Ettoihc.menubox#pack ~expand:false) ()

let volbox = GPack.hbox
	~width: 90
	~packing:(Ettoihc.menubox#pack ~expand:false) ()
	
let infobar = GButton.toolbar  
  ~orientation:`HORIZONTAL  
  ~style:`BOTH
  ~width:80
  ~packing:(Ettoihc.menubox#pack ~expand:false) ()

(* Fichier en cours de lecture *)
let soundText =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing:Ettoihc.soundbox#add () in
  let txt = GText.view 
    ~packing:scroll#add ()
    ~editable: false  
    ~cursor_visible: false in
  txt#misc#modify_font_by_name "Monospace 10";
  txt

(* Fonctions du menu *)
let actDisplay filepath =
  if (filepath = "") then
    filedisplay := ""
  else
    (begin
      if Meta.Id3v1.has_tag filepath then
		    let t = Meta.Id3v1.read_file filepath in
		    filedisplay := Meta.Id3v1.getTitle t ^ " - " ^ Meta.Id3v1.getArtist t
	    else
		    filedisplay := filepath
    end);
  soundText#buffer#set_text (!filedisplay)

let play () =
  actDisplay !Current.filepath;
  Wrap.play_sound(!Current.filepath);
  Ettoihc.pause := false

let precedent () =
  if (!Current.indexSong != 0) then
    begin
 	    Current.indexSong := !Current.indexSong - 1;
  	  Current.filepath := Playlist.getFile !Current.indexSong !Current.playList;
      actDisplay !Current.filepath;
  	  play ()
    end
  else
    begin
      if (!filedisplay != "") then
  	    begin
  	      Current.filepath := "";
          actDisplay "";
  	      Current.indexSong := 0;
  	      Ettoihc.pause := true;
  	      Wrap.stop_sound()
  	    end
    end;
  !Current.indexSong = 0
    
  
let suivant () =
  if (!Current.indexSong != List.length !Current.playList - 1) then
      begin
  	    Current.indexSong := !Current.indexSong + 1;
  	    Current.filepath := Playlist.getFile !Current.indexSong !Current.playList;
        actDisplay !Current.filepath;
  	    play ()
    end
  else
    begin
      if (!filedisplay != "") then
        begin
  	      Current.filepath := "";
          actDisplay "";
  	      Current.indexSong := 0;
  	      Ettoihc.pause := true;
  	      Wrap.stop_sound()
  	    end
    end;
  !Current.indexSong = List.length !Current.playList - 1
  

(* Bouton d'ouverture du fichier *) 
  
let open_button =
  let btn = GButton.tool_button 
    ~stock:`OPEN
    ~packing: toolbar#insert () in 
  ignore(btn#connect#clicked 
    (fun () ->
      Current.launchPlaylist ();
      Database.checkBiblio ()));
  btn

(* Bouton Save *)

let save_button =
  let btn = GButton.tool_button
    ~stock: `SAVE
    ~packing: toolbar#insert () in
  ignore(btn#connect#clicked Ettoihc.saveDialog );
  btn

let separator1 = GButton.separator_tool_item ~packing: toolbar#insert ()

(* Bouton Play/Pause *)

let btnplay = GButton.tool_button 
    ~stock:`MEDIA_PLAY
    ~label:"Play"
    ~packing:toolbar#insert ()
let btnpause = GButton.tool_button 
    ~stock:`MEDIA_PAUSE
    ~label:"Pause"
    ~packing:toolbar#insert ()

(* Bouton Stop *)

let stop_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_STOP
    ~label:"Stop"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> 
    Current.filepath := "";
    Current.indexSong := 0;
    actDisplay "";
    Wrap.stop_sound();
    btnpause#misc#hide (); 
    btnplay#misc#show ();));
  btn

(* Bouton Previous *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PREVIOUS
    ~label:"Previous"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> 
      if (precedent ()) then 
        begin
          btnpause#misc#hide (); 
          btnplay#misc#show ();
        end));
  btn

(* Bouton Next *)

let next_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_NEXT
    ~label:"Next"
    ~packing:toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> 
      if (suivant ()) then 
        begin
          btnpause#misc#hide (); 
          btnplay#misc#show ();
        end));
  btn

let separator2 = GButton.separator_tool_item ~packing: toolbar#insert()

(* Barre de volume *)
let volume=
  let file_vol = ref 50. in
  let vol_change vol_b() =
    file_vol := vol_b#adjustment#value;
    Wrap.vol_sound (!file_vol /. 100.) in
  let adj= GData.adjustment 
    ~value:50.  
    ~lower:0.
    ~upper:110.  
    ~step_incr:1. () in
  let volume_scale = GRange.scale `HORIZONTAL
    ~draw_value:true
    ~show:true
    ~digits: 0
    ~adjustment:adj
    ~packing:volbox#add () in 
  ignore(volume_scale#connect#value_changed (vol_change volume_scale));
  volume_scale

(* Bouton "A propos" *)
let about_button =
  let dlg = GWindow.about_dialog
    ~authors:["Nablah"]
    ~version:"1.0"
    ~website:"http://ettoihc.wordpress.com/"
    ~website_label:"Ettoihc Website"
    ~position:`CENTER_ON_PARENT
    ~parent:Ettoihc.window
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
  Wrap.init_sound();
  ignore(Ettoihc.window#event#connect#delete Ettoihc.confirm);
  ignore(btnpause#connect#clicked 
    (fun () -> btnplay#misc#show (); btnpause#misc#hide (); 
               Ettoihc.pause := true; Wrap.pause_sound ()));
  ignore(btnplay#connect#clicked 
  	(fun () -> if (!Current.filepath = "") then () else
          begin
            btnpause#misc#show (); btnplay#misc#hide ();
            Current.play (); play ()
          end)); 
  btnpause#misc#hide ();
  ignore(Ettoihc.playlistView#connect#row_activated 
            ~callback: (Current.on_row_activated Ettoihc.playlistView));
  Database.startBiblio ();
  Ettoihc.window#show ();
  GMain.main ();
  Wrap.destroy_sound()
