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
  let nmb = model#get ~row ~column:Ettoihc.nmbPlaylist in
  indexSong := nmb - 1;
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
