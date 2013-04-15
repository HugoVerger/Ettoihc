let filepath = ref ""
let indexSong = ref 0
let playList = ref []

let play () =
  if (!playList != []) then
    begin
      let tmp = List.nth !playList !indexSong in
      let tmp2 = match tmp with (_,_,a) -> a in
      if (List.length !playList != 0 && 
                (!Ettoihc.pause || (!filepath != tmp2))) then
        filepath := tmp2
    end

let fill (song, artist, path) =
  let iter = Ettoihc.storePlaylist#append () in
  Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.nmbPlaylist
                                              (List.length !playList);
  Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.songPlaylist song;
  Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.artistPlaylist artist;
  Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.pathPlaylist path;
  Ettoihc.playListForSave := !Ettoihc.playListForSave ^ path ^ "\n"

let launchPlaylist () =
  if (Ettoihc.get_extension !filepath) then
    begin
      if not (Playlist.addSong !filepath playList) then
        fill (List.nth !playList ((List.length !playList) -1))
    end
  else
    begin
      Playlist.cleanPlaylist playList indexSong;
      Wrap.stop_sound();
      Playlist.addPlaylist !filepath playList;
      List.iter fill !playList;
    end

let on_row_activated (view:GTree.view) path column =
  let model = view#model in
  let row = model#get_iter path in
  let nmb = model#get ~row ~column:Ettoihc.nmbPlaylist in
  indexSong := nmb - 1;
  play ();
  !Ettoihc.play ()

let cleanPlaylist () =
  Playlist.cleanPlaylist playList indexSong;
  filepath := "";
  Ettoihc.storePlaylist#clear ();
  Ettoihc.pause := true;
  Wrap.stop_sound ();
  !Ettoihc.stop ()

let rec actNmb = function
  |n when n = (List.length !playList) -> ()
  |n ->
    let iter = Ettoihc.storePlaylist#iter_children ~nth:n None in
    Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.nmbPlaylist n;
    actNmb (n+1)

let deleteList n =
  let elt = List.nth !playList (n - 1) in
  let rec delete = function
    |[] -> []
    |h::t when h = elt-> t
    |h::t -> h :: delete t in
  delete !playList

let removeSong path =
  let model = Ettoihc.playlistView#model in
  let row = model#get_iter path in
  let path = model#get ~row ~column:Ettoihc.pathPlaylist in
  let nmb = model#get ~row ~column:Ettoihc.nmbPlaylist in
  if not (nmb = 1) then
    begin
      let iter = Ettoihc.storePlaylist#iter_children ~nth:(nmb - 1) None in
      if path = !filepath then
        begin
          Ettoihc.pause := true;
          Wrap.stop_sound ();
          filepath := "";
          indexSong := 0;
          !Ettoihc.stop ()
        end;
      ignore(Ettoihc.storePlaylist#remove iter);
      actNmb (nmb);
      playList := deleteList nmb
    end
  else
    cleanPlaylist ()

let view_popup_menu treeview ev p=
  let menu = GMenu.menu () in
  let cleanItem = GMenu.menu_item
    ~label:"Clean Playlist"
    ~packing:menu#append () in
  let supItem = GMenu.menu_item
    ~label:"Remove"
    ~packing:menu#append () in
  ignore(cleanItem#connect#activate ~callback:(fun () -> cleanPlaylist ()));
  ignore(supItem#connect#activate ~callback:(fun () -> removeSong p));
  menu#popup
    ~button:(GdkEvent.Button.button ev)
    ~time:(GdkEvent.Button.time ev)

let on_button_pressed treeview ev =
  if GdkEvent.Button.button ev = 3 then
    begin
      let selection = treeview#selection in
      if selection#count_selected_rows <= 1 then
        begin
          let x = int_of_float (GdkEvent.Button.x ev) in
          let y = int_of_float (GdkEvent.Button.y ev) in
          match treeview#get_path_at_pos ~x ~y  with
            |Some(p,_,_,_) ->
              begin
                selection#unselect_all ();
                selection#select_path p;
                view_popup_menu treeview ev p;
              end
            |None -> ()
        end;
      true
    end
  else
    false

(* Tracé en arrière-plan. *)
let back = GDraw.pixmap ~width:350 ~height:350 ()

(* Boîte à outils pour le dessin. *)
let drawing = 
  Ettoihc.drawing_area#misc#realize ();
  new GDraw.drawable Ettoihc.drawing_area#misc#window

let reset_draw () =
  back#set_foreground (`NAME "#ffffff");
  back#rectangle ~x:0 ~y:0 ~width:350 ~height:350 ~filled:true ();
  drawing#put_pixmap ~x:0 ~y:0 back#pixmap

let set_draw () =
  back#set_foreground (`NAME "#000000");
  let n = ref 0 in
  let tab = Array.make 512 0. in
  Wrap.spectre_sound (tab);
  while (!n <= 350) do
    print_float (Array.get tab !n);
    let elt = (Array.get tab !n) *. 2000. *. 350. in
    back#line ~x:(!n) ~y:(int_of_float(elt)) ~x:(!n) ~y:350;
    n := !n + 1
  done;
  drawing#put_pixmap ~x:0 ~y:0 back#pixmap;
  print_string "\n";
  flush stdout

let timer = GMain.Timeout.add ~ms:20 ~callback:(fun() -> 
  if not (!Ettoihc.pause) then
    begin
      reset_draw ();
      set_draw ()
    end;
  true)
