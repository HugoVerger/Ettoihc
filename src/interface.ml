(* Declarations variables *)

let pause = ref true			(*Son en Cours*)
let filepath = ref ""
let indexSong = ref 0
let filedisplay = ref ""

let playListForDisplay = ref ""	(*Playlist en Cours*)
let playListFile = ref []

let biblioForDisplay = ref ""	(*Bibliotheque*)
let biblioFile = ref [""]


(* Zone de texte *)

let text =
  let scroll = GBin.scrolled_window
    ~hpolicy:`NEVER
    ~vpolicy:`NEVER
    ~shadow_type:`ETCHED_IN
    ~packing:Ettoihc.centerbox#add () in
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
    ~packing:Ettoihc.page2box#add () in
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
    ~packing:Ettoihc.page1box#add () in
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

let play () = 
  Playlist.actDisplay !filepath filedisplay;
  text#buffer#set_text (!filedisplay);
  Wrap.play_sound(!filepath)

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
  	    Wrap.stop_sound()
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
  	    Wrap.stop_sound()
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
			Ettoihc.biblioForSave := !Ettoihc.biblioForSave ^ !filepath ^ "\n";
			if Meta.Id3v1.has_tag !filepath then
				let t = Meta.Id3v1.read_file !filepath in
				biblioForDisplay := !biblioForDisplay ^
									Meta.Id3v1.getTitle t ^ 
									" - " ^ Meta.Id3v1.getArtist t ^ "\n"
			else
				biblioForDisplay := !filepath
		end
	

(* Bouton d'ouverture du fichier *) 
  
let open_button =
  let btn = GButton.tool_button 
    ~stock:`OPEN
    ~packing:Ettoihc.toolbar#insert () in 
  ignore(btn#connect#clicked 
    (fun () -> begin
      Ettoihc.openDialog filepath;
      checkBiblio();
    	(if (Playlist.get_extension !filepath) then
    	    Playlist.addSong !filepath filedisplay playListForDisplay
    	      Ettoihc.playListForSave playListFile
    	 else
    	    (Playlist.cleanPlaylist filedisplay playListForDisplay
    	       Ettoihc.playListForSave	playListFile indexSong 
    	       pause;
    	     Wrap.stop_sound();
    	     text#buffer#set_text "";
    	     Playlist.addPlaylist !filepath filedisplay playListForDisplay
    	       					Ettoihc.playListForSave playListFile));
    	playlist#buffer#set_text (!playListForDisplay);
    	biblioText#buffer#set_text (!biblioForDisplay)
    end));
  btn

(* Bouton Save *)

let save_button =
  let btn = GButton.tool_button
    ~stock: `SAVE
    ~packing: Ettoihc.toolbar#insert () in
  ignore(btn#connect#clicked Ettoihc.saveDialog );
  btn

let separator1 = 
  ignore (GButton.separator_tool_item ~packing:Ettoihc.toolbar#insert ())

(* Bouton Previous *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PREVIOUS
    ~label:"Previous"
    ~packing:Ettoihc.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> precedent ()));
  btn

(* Bouton Play *)
 
let play_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PLAY
    ~label:"Play"
    ~packing:Ettoihc.toolbar#insert () in
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
    ~packing:Ettoihc.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> pause := true; Wrap.pause_sound ()));
  btn

(* Bouton Stop *)

let stop_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_STOP
    ~label:"Stop"
    ~packing:Ettoihc.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> 
    filepath := "";
    filedisplay := "";
    indexSong := 0;
    Wrap.stop_sound();
    text#buffer#set_text (!filedisplay)));
  btn

(* Bouton Next *)

let next_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_NEXT
    ~label:"Next"
    ~packing:Ettoihc.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> suivant ()));
  btn

let separator2 = GButton.separator_tool_item ~packing:Ettoihc.toolbar#insert()


(* Bouton Volume *)

let file_vol = ref 50.
let adj= GData.adjustment 
  ~value:50.  ~lower:0.
  ~upper:110.  ~step_incr:1. () 

let vol_change vol_b() =
  file_vol := vol_b#adjustment#value;
  Wrap.vol_sound (!file_vol /. 100.)

let volume=
  let volume_button = GRange.scale `HORIZONTAL
    ~draw_value:true
    ~show:true
    ~digits: 0
    ~adjustment:adj
    ~packing:Ettoihc.volbox#add () in 
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
    ~parent:Ettoihc.window
    ~width: 400
    ~height: 150
    ~destroy_with_parent:true () in
  let btn = GButton.tool_button 
    ~stock:`ABOUT 
    ~packing:Ettoihc.infobar#insert () in
  ignore(btn#connect#clicked (fun () -> 
    ignore (dlg#run ()); dlg#misc#hide ()));
  btn

let distortion =
  let dbut = GButton.button
    ~show:true
    ~label:"Distorsion"
    ~relief:`NORMAL
    ~packing:Ettoihc.firstLine#add() in
  ignore(dbut#connect#clicked ~callback:Wrap.distortion_sound);
  dbut

let amelioration =
  let abut = GButton.button
    ~show:true
    ~label:"Amélioration du son"
    ~relief:`NORMAL
    ~packing:Ettoihc.firstLine#add() in
  ignore(abut#connect#clicked ~callback:Wrap.amelio_sound);
  abut

let flange=
  let fbut = GButton.button
    ~show:true
    ~label:"Flange"
    ~relief:`NORMAL
    ~packing:Ettoihc.firstLine#add() in
  ignore(fbut#connect#clicked ~callback:Wrap.flange_sound);
  fbut

let chorus =
  let cbut = GButton.button
    ~show:true
    ~label:"Chorus"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(cbut#connect#clicked ~callback:Wrap.chorus_sound);
  cbut

let echo =
  let ebut = GButton.button
    ~show:true
    ~label:"Echo"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(ebut#connect#clicked ~callback:Wrap.echo_sound);
  ebut

let lowpass=
  let lbut = GButton.button
    ~show:true
    ~label:"Low Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(lbut#connect#clicked ~callback:Wrap.lpasse_sound);
  lbut

let highpass=
  let hbut = GButton.button
    ~show:true
    ~label:"High Pass"
    ~relief:`NORMAL
    ~packing:Ettoihc.secondLine#add() in
  ignore(hbut#connect#clicked ~callback:Wrap.hpasse_sound);
  hbut


let _ =
  Wrap.init_sound();
  ignore(Ettoihc.window#event#connect#delete Ettoihc.confirm);
  Playlist.loadBiblio biblioForDisplay Ettoihc.biblioForSave biblioFile;
  biblioText#buffer#set_text (!biblioForDisplay);
  Ettoihc.window#show ();
  GMain.main ();
  Wrap.destroy_sound()
