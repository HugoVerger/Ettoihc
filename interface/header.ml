let filedisplay = ref ""
let lengthSong = ref 0
let lengthSongString = ref "00:00:00"
let timeSong = ref 0
let file_vol = ref 50.
let repeat = ref false

(*---------------------*)
(*  Structure du menu  *)
(*---------------------*)

let toolbar = GButton.toolbar
  ~orientation:`HORIZONTAL
  ~style:`BOTH
  ~width:520
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

let timeLine = GRange.progress_bar 
  ~packing:Ettoihc.timeLinebox#add ()


(* Bouton d'ouverture du fichier *) 
let open_button = GButton.tool_button
    ~stock:`OPEN
    ~packing: toolbar#insert ()

(* Bouton Save *)
let save_button = GButton.tool_button
    ~stock: `SAVE
    ~packing: toolbar#insert ()

let separator1 = GButton.separator_tool_item ~packing: toolbar#insert ()

(* Bouton Previous *)
let previous_button = GButton.tool_button
  ~stock:`MEDIA_PREVIOUS
  ~label:"Previous"
  ~packing:toolbar#insert ()

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
let stop_button = GButton.tool_button
  ~stock:`MEDIA_STOP
  ~label:"Stop"
  ~packing:toolbar#insert ()

(* Bouton Next *)
let next_button = GButton.tool_button
  ~stock:`MEDIA_NEXT
  ~label:"Next"
  ~packing:toolbar#insert ()

(* Bouton Repeat *)
let repeat_button = GButton.tool_button
  ~label:"Repeat"
  ~packing:toolbar#insert ()

let separator2 = GButton.separator_tool_item ~packing: toolbar#insert()

(* Barre de volume *)
let volume =
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
  volume_scale

(* Bouton "A propos" *)
let about_button =
  let btn = GButton.tool_button
    ~stock:`ABOUT
    ~packing:infobar#insert () in
  btn


(*---------------------*)
(*  Fonctions du menu  *)
(*---------------------*)


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

let stop () =
  Current.filepath := "";
  actDisplay "";
  Current.indexSong := 0;
  Ettoihc.pause := true;
  Wrap.stop_sound();
  lengthSongString := "00:00:00";
  btnpause#misc#hide ();
  btnplay#misc#show ();
  Current.play () (* Prépare prochaine musique *)

let precedent () =
  if not (!filedisplay = "") then
    begin
      if (!Current.indexSong != 0) then
        begin
          Current.indexSong := !Current.indexSong - 1;
          Current.filepath :=
          Playlist.getFile !Current.indexSong !Current.playList;
          actDisplay !Current.filepath;
          play ()
        end
      else
        if (!repeat) then
          begin
            Current.indexSong := List.length !Current.playList - 1;
            Current.play();
            !Ettoihc.play ()
          end
        else
          stop ()
    end

let suivant () =
  if not (!filedisplay = "") then
    begin
      if (!Current.indexSong != List.length !Current.playList - 1) then
        begin
          Current.indexSong := !Current.indexSong + 1;
          Current.filepath :=
              Playlist.getFile !Current.indexSong !Current.playList;
          actDisplay !Current.filepath;
          play ()
        end
      else
        if (!repeat) then
          begin
            Current.indexSong := 0;
            Current.play();
            !Ettoihc.play ()
          end
        else
          stop ()
    end

let vol_change vol_b() =
  file_vol := vol_b#adjustment#value;
  Wrap.vol_sound (!file_vol /. 100.)

let openFun () =
  let signal = ref "cancel" in
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
    end

let connectMenu () =
  ignore(volume#connect#value_changed    (vol_change volume));
  ignore(next_button#connect#clicked     (fun () -> suivant ()));
  ignore(previous_button#connect#clicked (fun () -> precedent ()));
  ignore(stop_button#connect#clicked     (fun () -> stop ()));
  ignore(save_button#connect#clicked     Ettoihc.saveDialog);
  ignore(open_button#connect#clicked     (fun () -> openFun ()));
  ignore(repeat_button#connect#clicked   (fun () -> repeat := not !repeat));
  ignore(about_button#connect#clicked    (fun () -> 
    ignore(Ettoihc.about#run ());
    Ettoihc.about#misc#hide ()));
  ignore(btnpause#connect#clicked        (fun () -> 
    btnplay#misc#show ();
    btnpause#misc#hide ();
    Ettoihc.pause := true;
    Wrap.pause_sound ()));
  ignore(btnplay#connect#clicked         (fun () ->
    if not (!Current.filepath = "") then
      begin
        btnpause#misc#show ();
        btnplay#misc#hide ();
        Current.play (); 
        play ()
      end));
  Ettoihc.play := (fun () -> 
    btnpause#misc#show (); 
    btnplay#misc#hide (); 
    play ());
  Ettoihc.stop := (fun () ->
    btnpause#misc#hide (); 
    btnplay#misc#show (); 
    actDisplay "");
  ()
