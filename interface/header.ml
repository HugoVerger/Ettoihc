let filedisplay = ref ""
let pulse_mode = ref false
let lengthSong = ref 0
let lengthSongString = ref "00:00:00"
let timeSong = ref 0

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
let actLengthSong () =
  lengthSong := Wrap.length_sound ();
  let min = (!lengthSong  / 1000) / 60 in
  let sec = (!lengthSong  / 1000) mod 60 in
  let ms = (!lengthSong  / 10) mod 100 in
  let minS = (if min < 10 then "0" else "") ^ string_of_int (min) in
  let secS = (if sec < 10 then "0" else "") ^ string_of_int (sec) in
  let msS = (if ms < 10 then "0" else "") ^ string_of_int (ms) in
  lengthSongString := minS ^ ":" ^ secS ^ ":" ^ msS

let actTimeLine pbar () =
  timeSong := Wrap.time_sound ();
  if (!pulse_mode) then
    pbar#pulse ()
  else
    begin
      if (!lengthSong = 0) then
        pbar#set_fraction 0.
      else
        pbar#set_fraction ((float)!timeSong /. (float)!lengthSong);
        let min = (!timeSong / 1000) / 60 in
        let sec = (!timeSong / 1000) mod 60 in
        let ms = (!timeSong / 10) mod 100 in
        let minS = (if min < 10 then "0" else "") ^ string_of_int (min) in
        let secS = (if sec < 10 then "0" else "") ^ string_of_int (sec) in
        let msS = (if ms < 10 then "0" else "") ^ string_of_int (ms) in
        let timeS = minS ^ ":" ^ secS ^ ":" ^ msS in
        pbar#set_text (timeS ^ " / " ^ !lengthSongString)
    end


let actDisplay filepath =
  if (filepath = "") then
    filedisplay := ""
  else
    begin
      if Meta.Id3v1.has_tag filepath then
        begin
          let title = ref "" and artist = ref "" in
          let t = Meta.v1_of_v2 (Meta.read_both_as_v2 filepath) in
          title := t.Meta.Id3v1.title ;
          artist := t.Meta.Id3v1.artist;
          filedisplay := !title ^ " - " ^ !artist
        end
      else
        filedisplay := filepath
    end;
  soundText#buffer#set_text (!filedisplay)

let play () =
  Wrap.play_sound(!Current.filepath);
  actLengthSong ();
  actDisplay !Current.filepath;
  Ettoihc.pause := false

let precedent () =
  let tmp = (!Current.indexSong != 0) in
  if not (!filedisplay = "") then
    begin
      if tmp then
        begin
          Current.indexSong := !Current.indexSong - 1;
          Current.filepath :=
              Playlist.getFile !Current.indexSong !Current.playList;
          actDisplay !Current.filepath;
          play ()
        end
      else
        begin
          Current.filepath := "";
          actDisplay "";
          Current.indexSong := 0;
          Ettoihc.pause := true;
          lengthSongString := "00:00:00";
          Wrap.stop_sound();
          Current.play ()
        end
    end;
  not tmp
    
  
let suivant () =
  let tmp = (!Current.indexSong != List.length !Current.playList - 1) in
  if not (!filedisplay = "") then
    begin
      if tmp then
        begin
          Current.indexSong := !Current.indexSong + 1;
          Current.filepath :=
              Playlist.getFile !Current.indexSong !Current.playList;
          actDisplay !Current.filepath;
          play ()
        end
      else
        begin
          Current.filepath := "";
          actDisplay "";
          Current.indexSong := 0;
          Ettoihc.pause := true;
          lengthSongString := "00:00:00";
          Wrap.stop_sound();
          Current.play ()
        end
    end;
  not tmp


(* Bouton d'ouverture du fichier *) 

let open_button =
  let btn = GButton.tool_button
    ~stock:`OPEN
    ~packing: toolbar#insert () in
  let signal = ref "cancel" in
  ignore(btn#connect#clicked (fun () ->
    Ettoihc.openDialog Current.filepath signal;
    if not (!signal = "cancel") then
      begin
        if !signal = "biblio" then
          Database.checkBiblio ()
        else
          begin
            if !signal = "play" then
              begin
                Current.indexSong := (List.length !Current.playList) - 1;
                Current.launchPlaylist ();
                Current.indexSong := !Current.indexSong + 1;
                Current.play();
                !Ettoihc.play ()
              end
          end
      end));
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
    actDisplay "";
    Current.indexSong := 0;
    Ettoihc.pause := true;
    Wrap.stop_sound();
    lengthSongString := "00:00:00";
    btnpause#misc#hide (); 
    btnplay#misc#show ();
    Current.play ()));
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
let volume =
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
    ~version:"1.1"
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

(* Range en cours de lecture *)
let timeLine = GRange.progress_bar ~packing:Ettoihc.timeLinebox#add ()

let timer = GMain.Timeout.add ~ms:1 ~callback:(fun () -> 
  actTimeLine timeLine ();
  if not (!Ettoihc.pause) then
    Wrap.spectre ();
  if (!lengthSong = !timeSong) then
    begin
      if (suivant ()) then
        begin
          btnpause#misc#hide ();
          btnplay#misc#show ();
        end
    end;
  true)
