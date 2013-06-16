let repeat = ref false
let random = ref false
let length = ref 0
let time = ref 0
let pause = ref true
let indexSong = ref 0


(** Actualisation Functions  **)

let actLengthSong () =
  length := Wrap.length_sound ();
  let min = (!length  / 1000) / 60 in
  let sec = (!length  / 1000) mod 60 in
  let ms = (!length  / 10) mod 100 in
  let minS = (if min < 10 then "0" else "") ^ string_of_int (min) in
  let secS = (if sec < 10 then "0" else "") ^ string_of_int (sec) in
  let msS = (if ms < 10 then "0" else "") ^ string_of_int (ms) in
  UiHeader.timeTotal#set_text (minS ^ ":" ^ secS ^ ":" ^ msS)

let actDisplay path iter =
  let title = (UiPage1.store#get 
    ~row:iter
    ~column: UiPage1.title) in
  let artist = (UiPage1.store#get 
    ~row:iter
    ~column: UiPage1.artist) in
  if title = "" then
    UiHeader.soundText#buffer#set_text path
  else
    UiHeader.soundText#buffer#set_text (title ^ " - " ^ artist)

let actTimeLine () =
  time := Wrap.time_sound ();
  if (!length = 0) then
    UiHeader.adjTime#set_value 0.
  else
    UiHeader.adjTime#set_value ((float)!time *. 1000. /. (float)!length);
  let min = (!time / 1000) / 60 in
  let sec = (!time / 1000) mod 60 in
  let ms = (!time / 10) mod 100 in
  let minS = (if min < 10 then "0" else "") ^ string_of_int (min) in
  let secS = (if sec < 10 then "0" else "") ^ string_of_int (sec) in
  let msS = (if ms < 10 then "0" else "") ^ string_of_int (ms) in
  UiHeader.timeCurrent#set_text (minS ^ ":" ^ secS ^ ":" ^ msS)


(** Properties **)

let getColor s =

  let convert_int s =
    let n = ref 0 in

    if (Char.code s.[0]) > 65 then
      n := (Char.code s.[0] - 65 + 10) * 16
    else
      n := (Char.code s.[0] - 48) * 16;

    if (Char.code s.[1]) > 65 then
      n := !n + Char.code s.[1] - 65 + 10
    else
      n := !n + Char.code s.[1] - 48;
    !n in

  let red = String.sub s 1 2 in
  let blue = String.sub s 3 2 in
  let green = String.sub s 5 2 in
  
  let c1 = convert_int red in
  let c2 = convert_int blue in
  let c3 = convert_int green in
  Gdk.Color.alloc 
    ~colormap:(Gdk.Color.get_system_colormap ()) (`RGB(c1,c2,c3))


let convert_hexa n =
  let string_of_char = String.make 1 in
  let s1 = ref '0' and s2 = ref '0' in
  if n/256 > 15 then
    begin
      let tmp = (n /256 / 16) in
      if tmp > 9 then
        begin
          let tmp2 = tmp + 65 - 10 in
          s1 := Char.chr tmp2
        end
    end;
  let tmp = (n /256 mod 16) in
  if tmp > 9 then
    begin
      let tmp2 = tmp + 65 - 10 in
      s2 := Char.chr tmp2
    end;
  (string_of_char !s1) ^ string_of_char (!s2)

let colorChange color =
  let dlg = Ui.colorSelect () in
  dlg#colorsel#set_color (getColor color);


  let tmp = ref color in
  ignore(dlg#ok_button#connect#clicked (fun () -> 
    let c = dlg#colorsel#color in
    tmp := "#" ^ convert_hexa (Gdk.Color.red c) 
               ^ convert_hexa (Gdk.Color.green c)
               ^ convert_hexa(Gdk.Color.blue c)));

  ignore (dlg#run ()); 
  dlg#destroy ();
  !tmp

let properties () =
  let dlg = Ui.properties () in
  let bbox = Ui.frameButton dlg in
  let color = Ui.frameColor dlg in

  (List.nth bbox 4)#set_active UiPage2.colName#visible;
  (List.nth bbox 3)#set_active UiPage2.colArtist#visible;
  (List.nth bbox 2)#set_active UiPage2.colAlbum#visible;
  (List.nth bbox 1)#set_active UiPage2.colGenre#visible;
  (List.nth bbox 0)#set_active UiPage2.colPath#visible;

  let color1 = ref !UiPage1.colorBar in
  ignore((List.nth color 1)#connect#clicked (fun () -> 
    color1 := colorChange !color1));

  let color2 = ref !UiPage1.colorBack in
  ignore((List.nth color 0)#connect#clicked (fun () -> 
    color2 := colorChange !color2));

  let res = dlg#run () in

  if res = `SAVE then
    begin
      UiPage2.colName#set_visible ((List.nth bbox 4)#active);
      UiPage2.colArtist#set_visible ((List.nth bbox 3)#active);
      UiPage2.colAlbum#set_visible ((List.nth bbox 2)#active);
      UiPage2.colGenre#set_visible ((List.nth bbox 1)#active);
      UiPage2.colPath#set_visible ((List.nth bbox 0)#active);
      UiPage1.colorBar := !color1;
      UiPage1.colorBack := !color2;
    end;
  dlg#destroy ()

(** Connecting UI/functions **)

let play () =
  if (!UiPage1.nbSong > 0) && !pause  then
    begin
      UiHeader.timeLine#misc#show ();
      UiHeader.timeCurrent#misc#show ();
      UiHeader.timeTotal#misc#show ();
      UiHeader.pause#misc#show ();
      UiHeader.play#misc#hide ();
      UiHeader.adjTime#set_value 0.;

      let iter = UiPage1.store#iter_children ~nth: (!indexSong - 1) None in
      let file = (UiPage1.store#get ~row: iter ~column: UiPage1.path) in
      Wrap.play_sound file;
      pause := false;

      actDisplay file iter;
      actLengthSong ()
    end

let pauseFun () =
  if not !pause then
    begin
      UiHeader.pause#misc#hide ();
      UiHeader.play#misc#show ();

      pause := true;
      Wrap.pause_sound ()
    end

let stop () =
  UiHeader.pause#misc#hide ();
  UiHeader.play#misc#show ();
  UiHeader.timeLine#misc#hide ();
  UiHeader.timeCurrent#misc#hide ();
  UiHeader.timeTotal#misc#hide ();
  UiHeader.soundText#buffer#set_text "";

  time := 0;
  indexSong := 1;
  pause := true;
  Wrap.stop_sound ()

let previous () =
  if (!UiPage1.nbSong > 0) & (!indexSong > 1) then
    begin
      pause := true;
      indexSong := !indexSong - 1;
      play ()
    end
  else if (!UiPage1.nbSong > 0) &&(!repeat) then
    begin
      pause := true;
      indexSong := !UiPage1.nbSong;
      play ();
    end
  else
    stop ()

let next () =
  if ((!UiPage1.nbSong > 0) && (!indexSong < !UiPage1.nbSong)) then
    begin
      pause := true;
      indexSong := !indexSong + 1;
      play ()
    end
  else 
    begin
      if ((!UiPage1.nbSong > 0) && (!repeat)) then
        begin
          pause := true;
          indexSong := 1;
          play ()
        end
      else
        stop ()
    end

let save () =
  let str_op = function
    |Some x -> x
    |_ -> failwith "Need a file" in

  let rec print file =
    let oc = open_out file in
    let store = UiPage1.store in
    let first = store#get_iter_first in
    begin
      match first with
      |Some iter ->
        Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:UiPage1.path);

        while store#iter_next iter do
          Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:UiPage1.path)
        done
      |None -> ()
      end;
      close_out oc in

  let dlg = Ui.save () in
  if (dlg#run () = `SAVE) then
    print (str_op(dlg#filename) ^ ".m3u");
  dlg#destroy ()

let repeatFun () =
  repeat := not !repeat

let rec createRandom = function
  |n when n < !UiPage1.nbSong ->
    begin
      let iter = UiPage1.store#iter_children ~nth:n None in
      let old = UiPage1.store#get ~row:iter ~column:UiPage1.nmb in

      let rec findNewNmb () =
        let tmp = Random.int (!UiPage1.nbSong + 1) in
        if tmp = old || tmp = 0 then
          findNewNmb ()
        else
          tmp in

      let newN = findNewNmb () in

      let rec newAlreadyAttributed = function
        |i when i > n -> false
        |i ->
          begin
            let iter2 = UiPage1.store#iter_children ~nth: i None in
            let tmp = UiPage1.store#get ~row: iter2 ~column: UiPage1.random in
            if (tmp != newN) then
              newAlreadyAttributed (i + 1)
            else
              true
          end in

      if not (newAlreadyAttributed 0) then
        begin
          UiPage1.store#set ~row: iter ~column: UiPage1.random newN;
          createRandom (n + 1)
        end
      else
        createRandom n
    end
  |_ -> ()

let randomFun () =
  random := not !random;
  if (!random && !UiPage1.nbSong > 1) then
    begin
      createRandom 0;

      let iter = UiPage1.store#iter_children ~nth: (!indexSong - 1) None in
      let newIndex = UiPage1.store#get ~row: iter ~column: UiPage1.random in
      indexSong := newIndex - 1;
      
      UiPage1.store#set_sort_column_id 1 `ASCENDING;
      UiPage1.playlistNmb#set_visible false;
      UiPage1.playlistRandom#set_visible true;
    end
  else if (!UiPage1.nbSong > 1) then
    begin
      let rec clean = function
        |n when n < !UiPage1.nbSong ->
          let iter = UiPage1.store#iter_children ~nth:n None in
          UiPage1.store#set ~row:iter ~column:UiPage1.random 0;
          clean (n+1)
        |_ -> () in

      clean 0;
      UiPage1.store#set_sort_column_id 0 `ASCENDING;
      UiPage1.playlistNmb#set_visible true;
      UiPage1.playlistRandom#set_visible false
    end

let volume () =
  Wrap.vol_sound (UiHeader.volume#adjustment#value /. 100.)

let about () =
  ignore(Ui.about#run ());
  Ui.about#misc#hide ()

let mouse ev =
  pause := true;
  Wrap.pause_sound ();
  let x = GdkEvent.Button.x ev in
  UiHeader.adjTime#set_value ((x -. 13.5) /. 0.63);
  Wrap.setTime (UiHeader.adjTime#value /. 1000.);
  true

let release _ =
  pause := false; 
  Wrap.pause_sound ();
  true

let connectUI () =

  ignore(UiHeader.play#connect#clicked                  play);
  ignore(UiHeader.pause#connect#clicked                 pauseFun);
  ignore(UiHeader.stop#connect#clicked                  stop);
  ignore(UiHeader.previous#connect#clicked              previous);
  ignore(UiHeader.next#connect#clicked                  next);
  ignore(UiHeader.save#connect#clicked                  save);
  ignore(UiHeader.repeat#connect#clicked                repeatFun);
  ignore(UiHeader.alea#connect#clicked                  randomFun);
  ignore(UiHeader.volume#connect#value_changed          volume);
  ignore(UiHeader.about#connect#clicked                 about);
  ignore(UiHeader.pref#connect#clicked                  properties);
  ignore(UiHeader.timeLine#event#connect#button_press   mouse);
  ignore(UiHeader.timeLine#event#connect#button_release release);

  UiHeader.pause#misc#hide ()
