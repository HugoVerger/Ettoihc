(* Declarations variables *)

		(*Son en Cours*)
let filepath = ref ""
let indexSong = ref 0

let playListForDisplay = ref ""	(*Playlist en Cours*)
let playListFile = ref []

let biblioForDisplay = ref ""	(*Bibliotheque*)
let biblioFile = ref [""]

(* Declaration fonctions *)

let play () =
  Header.actDisplay !filepath;
  Wrap.play_sound(!filepath)

let precedent = (fun () ->
  if (!indexSong != 0) then
      begin
  	    indexSong := !indexSong - 1;
  	    filepath := List.nth !playListFile !indexSong;
        Header.actDisplay !filepath;
  	    play ()
      end
   else
      (if (!Header.filedisplay != "") then
  	  begin
  	    filepath := "";
        Header.actDisplay "";
  	    indexSong := 0;
  	    Wrap.stop_sound()
  	  end
      )
  )
  
let suivant = (fun () ->
  if (!indexSong != List.length !playListFile - 1) then
      begin
  	    indexSong := !indexSong + 1;
  	    filepath := List.nth !playListFile !indexSong;
        Header.actDisplay !filepath;
  	    play ()
      end
   else
      (if (!Header.filedisplay != "") then
  	  begin
  	    filepath := "";
        Header.actDisplay "";
  	    indexSong := 0;
  	    Wrap.stop_sound()
  	  end
      )
  )

let checkBiblio () =
	let rec noExist = function
		|[] -> true
		|h::t when h = !filepath -> false
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
    ~packing:Header.toolbar#insert () in 
  ignore(btn#connect#clicked 
    (fun () -> begin
      Ettoihc.openDialog filepath;
      checkBiblio();
    	(if (Playlist.get_extension !filepath) then
    	    Playlist.addSong !filepath Header.filedisplay playListForDisplay
    	      Ettoihc.playListForSave playListFile
    	 else
    	    (Playlist.cleanPlaylist playListForDisplay
    	       Ettoihc.playListForSave	playListFile indexSong;
    	     Wrap.stop_sound();
           Header.actDisplay !filepath;
    	     Playlist.addPlaylist !filepath Header.filedisplay playListForDisplay
    	       					Ettoihc.playListForSave playListFile));
    	Ettoihc.playlist#buffer#set_text (!playListForDisplay);
    	Ettoihc.biblioText#buffer#set_text (!biblioForDisplay)
    end));
  btn

(* Bouton Save *)

let save_button =
  let btn = GButton.tool_button
    ~stock: `SAVE
    ~packing: Header.toolbar#insert () in
  ignore(btn#connect#clicked Ettoihc.saveDialog );
  btn

let separator1 = 
  ignore (GButton.separator_tool_item ~packing:Header.toolbar#insert ())

(* Bouton Previous *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PREVIOUS
    ~label:"Previous"
    ~packing:Header.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> precedent ()));
  btn

(* Bouton Play *)
 
let play_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PLAY
    ~label:"Play"
    ~packing:Header.toolbar#insert () in
  ignore(btn#connect#clicked 
  	(fun () ->
  		if (List.length !playListFile != 0 && 
  		(!Ettoihc.pause || (!filepath != List.nth !playListFile !indexSong))) then
  			(filepath := List.nth !playListFile !indexSong;
    		play ();
    		Ettoihc.pause := false)));
  btn

(* Bouton Pause *)

let previous_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_PAUSE
    ~label:"Pause"
    ~packing:Header.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> Ettoihc.pause := true; Wrap.pause_sound ()));
  btn

(* Bouton Stop *)

let stop_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_STOP
    ~label:"Stop"
    ~packing:Header.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> 
    filepath := "";
    Header.actDisplay "";
    indexSong := 0;
    Wrap.stop_sound()));
  btn

(* Bouton Next *)

let next_button =
  let btn = GButton.tool_button 
    ~stock:`MEDIA_NEXT
    ~label:"Next"
    ~packing:Header.toolbar#insert () in
  ignore(btn#connect#clicked (fun () -> suivant ()));
  btn

let separator2 = GButton.separator_tool_item ~packing:Header.toolbar#insert()


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
  Ettoihc.biblioText#buffer#set_text (!biblioForDisplay);
  Ettoihc.window#show ();
  GMain.main ();
  Wrap.destroy_sound()
