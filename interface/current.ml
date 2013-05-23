let filepath = ref ""
let indexSong = ref 0

let play () =
  if (!Playlist.nbSong != 0) then
    begin
      let iter = Ettoihc.storePlaylist#iter_children ~nth:(!indexSong) None in
      let file = (Ettoihc.storePlaylist#get ~row:iter
                                            ~column:Ettoihc.pathPlaylist) in
      if (!Ettoihc.pause || (!filepath != file)) then
        filepath := file
    end

let launchPlaylist () =
  if (Ettoihc.get_extension !filepath) then
    ignore(Playlist.addSong !filepath)
  else
    begin
      Playlist.cleanPlaylist indexSong;
      Wrap.stop_sound();
      Playlist.addPlaylist !filepath
    end

let on_row_activated (view:GTree.view) path column =
  let model = view#model in
  let row = model#get_iter path in
  let nmb = ref 0 in
  if (!Ettoihc.random) then
    nmb := model#get ~row ~column:Ettoihc.randomPlaylist
  else
    nmb := model#get ~row ~column:Ettoihc.nmbPlaylist;
  indexSong := !nmb - 1;
  play ();
  !Ettoihc.play ()

let cleanPlaylist () =
  Playlist.cleanPlaylist indexSong;
  filepath := "";
  Ettoihc.storePlaylist#clear ();
  Ettoihc.pause := true;
  Wrap.stop_sound ();
  !Ettoihc.stop ()

let rec actNmb = function
  |n when n > !Playlist.nbSong -> ()
  |n ->
    let iter = Ettoihc.storePlaylist#iter_children ~nth:(n- 1) None in
    Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.nmbPlaylist (n - 1);
    actNmb (n+1)

let removeSong path =
  if (!Playlist.nbSong = 1) then
    cleanPlaylist ()
  else
    begin
      let model = Ettoihc.playlistView#model in
      let row = model#get_iter path in
      let path = model#get ~row ~column:Ettoihc.pathPlaylist in
      let nmb = model#get ~row ~column:Ettoihc.nmbPlaylist in
      actNmb (nmb + 1);
      if path = !filepath then
        begin
          Ettoihc.pause := true;
          Wrap.stop_sound ();
          filepath := "";
          indexSong := 0;
          !Ettoihc.stop ()
        end;
      ignore(Ettoihc.storePlaylist#remove row);
      Playlist.nbSong := !Playlist.nbSong - 1
    end

let downSong path =
  let model = Ettoihc.playlistView#model in
  let row = model#get_iter path in
  let path = model#get ~row ~column:Ettoihc.pathPlaylist in
  
  if (!Ettoihc.random) then
    begin
      let nmb = model#get ~row ~column:Ettoihc.randomPlaylist in
      if (!Playlist.nbSong != nmb) then
        begin
          let iter = model#iter_children ~nth:(nmb) None in
          let path2 = model#get ~row:iter ~column:Ettoihc.pathPlaylist in
      
          if path = !filepath then
            indexSong := nmb;
          if path2 = !filepath then
            indexSong := nmb - 1;
        
          Ettoihc.storePlaylist#set ~row:row 
                                    ~column:Ettoihc.randomPlaylist (nmb+1);
          Ettoihc.storePlaylist#set ~row:iter
                                    ~column:Ettoihc.randomPlaylist (nmb);
          Ettoihc.storePlaylist#set_sort_column_id 1 `ASCENDING
        end
    end
  else
    begin
      let nmb = model#get ~row ~column:Ettoihc.nmbPlaylist in
      if (!Playlist.nbSong != nmb) then
        begin
          let iter = model#iter_children ~nth:(nmb) None in
          let path2 = model#get ~row:iter ~column:Ettoihc.pathPlaylist in
      
          if path = !filepath then
            indexSong := nmb;
          if path2 = !filepath then
            indexSong := nmb - 1;
        
          Ettoihc.storePlaylist#set ~row:row
                                    ~column:Ettoihc.nmbPlaylist (nmb + 1);
          Ettoihc.storePlaylist#set ~row:iter
                                    ~column:Ettoihc.nmbPlaylist (nmb);
          Ettoihc.storePlaylist#set_sort_column_id 0 `ASCENDING
        end
    end

let upSong path =
  let model = Ettoihc.playlistView#model in
  let row = model#get_iter path in
  let path = model#get ~row ~column:Ettoihc.pathPlaylist in

  if (!Ettoihc.random) then
    begin
      let nmb = model#get ~row ~column:Ettoihc.randomPlaylist in
      if (nmb != 1) then
        begin
          let iter = model#iter_children ~nth:(nmb - 2) None in
          let path2 = model#get ~row:iter ~column:Ettoihc.pathPlaylist in

          if path = !filepath then
            indexSong := nmb - 2;
          if path2 = !filepath then
            indexSong := nmb - 1;

          Ettoihc.storePlaylist#set ~row:row 
                                    ~column:Ettoihc.randomPlaylist (nmb - 1);
          Ettoihc.storePlaylist#set ~row:iter
                                    ~column:Ettoihc.randomPlaylist (nmb);
          Ettoihc.storePlaylist#set_sort_column_id 1 `ASCENDING
        end
    end
  else
    begin
      let nmb = model#get ~row ~column:Ettoihc.nmbPlaylist in
      if (nmb != 1) then
        begin
          let iter = model#iter_children ~nth:(nmb - 2) None in
          let path2 = model#get ~row:iter ~column:Ettoihc.pathPlaylist in

          if path = !filepath then
            indexSong := nmb - 2;
          if path2 = !filepath then
            indexSong := nmb - 1;

          Ettoihc.storePlaylist#set ~row:row
                                    ~column:Ettoihc.nmbPlaylist (nmb - 1);
          Ettoihc.storePlaylist#set ~row:iter
                                    ~column:Ettoihc.nmbPlaylist (nmb);
          Ettoihc.storePlaylist#set_sort_column_id 0 `ASCENDING
        end
    end

let view_popup_menu treeview ev p=
  let menu = GMenu.menu () in
  let upItem = GMenu.menu_item
    ~label:"Go Up"
    ~packing:menu#append () in
  let downItem = GMenu.menu_item
    ~label:"Go Down"
    ~packing:menu#append () in
  let cleanItem = GMenu.menu_item
    ~label:"Clean Playlist"
    ~packing:menu#append () in
  let supItem = GMenu.menu_item
    ~label:"Remove"
    ~packing:menu#append() in
  ignore(cleanItem#connect#activate ~callback:(fun () -> cleanPlaylist ()));
  ignore(supItem#connect#activate ~callback:(fun () -> removeSong p));
  ignore(downItem#connect#activate ~callback:(fun () -> downSong p));
  ignore(upItem#connect#activate ~callback:(fun () -> upSong p));
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
let back = GDraw.pixmap ~width:512 ~height:350 ()

(* Boîte à outils pour le dessin. *)
let drawing =
  Ettoihc.drawing_area#misc#realize ();
  new GDraw.drawable Ettoihc.drawing_area#misc#window

let reset_draw () =
  back#set_foreground (`NAME "#000000");
  back#rectangle ~x:0 ~y:0 ~width:512 ~height:350 ~filled:true ();
  drawing#put_pixmap ~x:0 ~y:0 back#pixmap

let set_draw () =
  back#set_foreground (`NAME "#ffffff");
  let n = ref 0 in
  let tab = Array.make 512 0. in
  Wrap.spectre_sound (tab);
  while (!n < 512) do
    let elt = min ((Array.get tab !n) *. 20. *. 350.) 350. in
    back#line ~x:(!n) ~y:(350 - int_of_float(elt)) ~x:(!n) ~y:0;
    n := !n + 1
  done;
  drawing#put_pixmap ~x:0 ~y:0 back#pixmap
