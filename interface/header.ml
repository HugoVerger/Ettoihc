let filedisplay = ref ""
let lengthSong = ref 0
let timeSong = ref 0
let file_vol = ref 50.
let timeSet = ref true
let repeat = ref false
let randomList = []

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
  ~packing:(Ettoihc.menubox#pack ~expand:true) ()

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

let timeText1 = GMisc.label
  ~width:40
  ~text:"00:00:00"
  ~show:false
  ~packing:Ettoihc.timeLinebox#add ()

let adjTime = GData.adjustment
  ~value:0.
  ~lower:0.
  ~upper:1010.
  ~step_incr:1. ()
let timeLine = 
  let b = GPack.hbox
    ~width:630
    ~packing:Ettoihc.timeLinebox#add () in
  GRange.scale `HORIZONTAL
    ~adjustment:adjTime
    ~show:false
    ~packing:b#add ()

let timeText2 = GMisc.label
  ~width:40
  ~text:"00:00:00"
  ~show:false
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


let boxLectureMode =
  let item = GButton.tool_item
    ~packing:toolbar#insert () in
  GPack.vbox
    ~packing:item#add ()

(* Bouton Aléatoire *)
let alea_button = GButton.toggle_button
  ~label:"Random"
  ~packing:boxLectureMode#add ()

(* Bouton Repeat *)
let repeat_button = GButton.toggle_button
  ~label:"Repeat"
  ~packing:boxLectureMode#add ()

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

(* Bouton "Préférence" *)
let pref_button =
  let btn = GButton.tool_button
    ~stock:`PROPERTIES
    ~packing:infobar#insert () in
  btn

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
  timeText2#set_text (minS ^ ":" ^ secS ^ ":" ^ msS)

let actTimeLine () =
  timeSong := Wrap.time_sound ();
  if (!lengthSong = 0) then
    adjTime#set_value 0.
  else
    adjTime#set_value ((float)!timeSong *. 1000. /. (float)!lengthSong);
  let min = (!timeSong / 1000) / 60 in
  let sec = (!timeSong / 1000) mod 60 in
  let ms = (!timeSong / 10) mod 100 in
  let minS = (if min < 10 then "0" else "") ^ string_of_int (min) in
  let secS = (if sec < 10 then "0" else "") ^ string_of_int (sec) in
  let msS = (if ms < 10 then "0" else "") ^ string_of_int (ms) in
  timeText1#set_text (minS ^ ":" ^ secS ^ ":" ^ msS)

let mouse t ev =
  Ettoihc.pause := true;
  Wrap.pause_sound ();
  let x = GdkEvent.Button.x ev in
  adjTime#set_value ((x -. 13.5) /. 0.63);
  Wrap.setTime (adjTime#value /. 1000.);
  timeSet := true;
  true

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
  adjTime#set_value 0.;
  actDisplay !Current.filepath;
  timeLine#misc#show ();
  timeText1#misc#show ();
  timeText2#misc#show ();
  Ettoihc.pause := false

let stop () =
  Current.filepath := "";
  actDisplay "";
  Current.indexSong := 0;
  Ettoihc.pause := true;
  Wrap.stop_sound();
  timeText2#set_text "00:00:00";
  btnpause#misc#hide ();
  timeLine#misc#hide ();
  timeText1#misc#hide ();
  timeText2#misc#hide ();
  btnplay#misc#show ();
  Current.play () (* Prépare prochaine musique *)

let precedent () =
  if not (!filedisplay = "") then
    begin
      if (!Current.indexSong != 0) then
        begin
          Current.indexSong := !Current.indexSong - 1;
          let iter = Ettoihc.storePlaylist#iter_children 
                                              ~nth:(!Current.indexSong) None in
          Current.filepath := (Ettoihc.storePlaylist#get ~row:iter
                                                ~column:Ettoihc.pathPlaylist);
          actDisplay !Current.filepath;
          play ()
        end
      else
        if (!repeat) then
          begin
            Current.indexSong := !Playlist.nbSong - 1;
            Current.play();
            !Ettoihc.play ()
          end
        else
          stop ()
    end

let rec suivant () =
  if not (!filedisplay = "") then
    begin
      if (!Current.indexSong != !Playlist.nbSong - 1) then
        begin
          Current.indexSong := !Current.indexSong + 1;
          let iter = Ettoihc.storePlaylist#iter_children 
                                              ~nth:(!Current.indexSong) None in
          Current.filepath := (Ettoihc.storePlaylist#get ~row:iter
                                                ~column:Ettoihc.pathPlaylist);
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
        if not (Sys.is_directory !Current.filepath) then
          Database.checkBiblio ()
        else
          begin
            let tmp = !Current.filepath in
            Array.iter (fun a -> Current.filepath := tmp ^"/"^ a;
                                 Database.checkBiblio ())
                       (Sys.readdir !Current.filepath);
          end
      else
        begin
          if !signal = "play" then
            begin
              if not (Sys.is_directory !Current.filepath) then
                begin
                  Current.indexSong := !Playlist.nbSong - 1;
                  Current.launchPlaylist ();
                  Current.indexSong := !Current.indexSong + 1;
                  Current.play();
                  !Ettoihc.play ()
                end
              else
                begin
                  let tmp = !Current.filepath in
                  Current.indexSong := !Playlist.nbSong - 1;
                  Array.iter (fun a -> Current.filepath := tmp ^"/"^ a;
                                       Current.launchPlaylist ())
                             (Sys.readdir !Current.filepath);
                  if not (!Current.indexSong = !Playlist.nbSong - 1) then
                    begin
                      Current.indexSong := !Current.indexSong + 1;
                      Current.play();
                      !Ettoihc.play ()
                    end
                end
            end
        end
    end

let rec createRandom = function
  |n when n < !Playlist.nbSong ->
    begin
      let iter = Ettoihc.storePlaylist#iter_children ~nth:n None in
      let old = Ettoihc.storePlaylist#get ~row:iter
                                                 ~column:Ettoihc.nmbPlaylist in
      let rec findR () =
        let tmp = Random.int (!Playlist.nbSong + 1) in
        if tmp = old then
          findR ()
        else
          tmp in
        let rnd = findR () in
        let rec iterCheck = function
          |i when i > n -> false
          |i ->
            begin
              let iter2 = Ettoihc.storePlaylist#iter_children ~nth:i None in
              let tmp = Ettoihc.storePlaylist#get ~row:iter2
                                      ~column:Ettoihc.randomPlaylist in
              if (tmp != rnd) then
                iterCheck (i + 1)
              else
                true
            end in
        if not (iterCheck 0) then
          begin
            Ettoihc.storePlaylist#set ~row:iter
                                      ~column:Ettoihc.randomPlaylist rnd;
            createRandom (n + 1)
          end
        else
          createRandom n
    end
  |_ -> ()

let randomFunc () =
  let compare a b =
    if a < b then -1
    else if a > b then 1
    else 0 in
  let sort_by_nmb (model:#GTree.model) row1 row2 =
    let name1 = model#get ~row:row1 ~column:Ettoihc.nmbPlaylist in
    let name2 = model#get ~row:row2 ~column:Ettoihc.nmbPlaylist in
    compare name1 name2 in
  let sort_by_random (model:#GTree.model) row1 row2 =
    let name1 = model#get ~row:row1 ~column:Ettoihc.randomPlaylist in
    let name2 = model#get ~row:row2 ~column:Ettoihc.randomPlaylist in
    compare name1 name2 in
  Ettoihc.storePlaylist#set_sort_func 0 sort_by_nmb;
  Ettoihc.storePlaylist#set_sort_func 1 sort_by_random;
  Ettoihc.random := not !Ettoihc.random;
  if (!Ettoihc.random && !Playlist.nbSong > 0) then
    begin
      Ettoihc.playlistNmb#set_visible false;
      Ettoihc.playlistRandom#set_visible true;
      createRandom 0;
      let rec actCurrent n =
        let iter = Ettoihc.storePlaylist#iter_children ~nth:n None in
        let tmp = Ettoihc.storePlaylist#get ~row:iter
                                            ~column:Ettoihc.pathPlaylist in
        if (tmp = !Current.filepath) then
          Current.indexSong := n + 1
        else
          actCurrent (n+1) in
       actCurrent 0;
      Ettoihc.storePlaylist#set_sort_column_id 1 `ASCENDING;
    end
  else
    begin
      alea_button#set_active false;
      let rec clean = function
        |n when n < !Playlist.nbSong ->
          let iter = Ettoihc.storePlaylist#iter_children ~nth:n None in
          Ettoihc.storePlaylist#set ~row:iter
                                    ~column:Ettoihc.randomPlaylist 0;
          clean (n+1)
        |_ -> () in
      clean 0;
      Ettoihc.storePlaylist#set_sort_column_id 0 `ASCENDING;
      Ettoihc.playlistNmb#set_visible true;
      Ettoihc.playlistRandom#set_visible false
    end


let connectMenu () =
  Random.init 42;
  ignore(volume#connect#value_changed    (vol_change volume));
  ignore(next_button#connect#clicked     (fun () -> suivant ()));
  ignore(previous_button#connect#clicked (fun () -> precedent ()));
  ignore(stop_button#connect#clicked     (fun () -> stop ()));
  ignore(save_button#connect#clicked     Ettoihc.saveDialog);
  ignore(open_button#connect#clicked     (fun () -> openFun ()));
  ignore(repeat_button#connect#clicked   (fun () -> repeat := not !repeat));
  ignore(alea_button#connect#clicked     (fun () -> randomFunc ()));
  ignore(about_button#connect#clicked    (fun () ->
    ignore(Ettoihc.about#run ());
    Ettoihc.about#misc#hide ()));
  ignore(pref_button#connect#clicked     (fun () -> Ettoihc.pref ()));
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
  ignore(timeLine#event#connect#button_press (mouse timeLine));
  ignore(timeLine#event#connect#button_release (fun ev -> 
    Ettoihc.pause := false; 
    Wrap.pause_sound ();
    true));
  ()
