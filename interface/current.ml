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
      
let launchPlaylist () =
  let fill (song, artist, path) =
    let iter = Ettoihc.storePlaylist#append () in
    Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.nmbPlaylist 
                                                (List.length !playList);
    Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.songPlaylist song;
    Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.artistPlaylist artist;
    Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.pathPlaylist path;
    Ettoihc.playListForSave := !Ettoihc.playListForSave ^ path ^ "\n";
  in
  if (Ettoihc.get_extension !filepath) then
    begin
      if (Playlist.addSong !filepath playList) then () else
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


let remove_nth n =
  let iter = Ettoihc.storePlaylist#iter_children ~nth:n None in
  Ettoihc.storePlaylist#remove iter


let cleanPlaylist () =
  Playlist.cleanPlaylist playList indexSong;
  filepath := "";
  Ettoihc.storePlaylist#clear ();
  Ettoihc.pause := true;
  Wrap.stop_sound ();
  !Ettoihc.stop ()

let view_popup_menu treeview ev =
  let menu = GMenu.menu () in
  let menuitem = GMenu.menu_item 
    ~label:"Clean Playlist"
    ~packing:menu#append () in
  ignore(menuitem#connect#activate ~callback:(fun () -> cleanPlaylist ()));
  menu#popup 
    ~button:(GdkEvent.Button.button ev)
    ~time:(GdkEvent.Button.time ev)

let on_button_pressed treeview ev =
  if GdkEvent.Button.button ev = 3 then (

    (* optional: select row if no row is selected or only
     *  one other row is selected (will only do something
     *  if you set a tree selection mode as described later
     *  in the tutorial) *)
    if true then begin
      let selection = treeview#selection in

      (* Note: gtk_tree_selection_count_selected_rows() does not
       *   exist in gtk+-2.0, only in gtk+ >= v2.2 ! *)
      if selection#count_selected_rows <= 1 then (
    	let x = int_of_float (GdkEvent.Button.x ev) in
    	let y = int_of_float (GdkEvent.Button.y ev) in
        let path = match treeview#get_path_at_pos ~x ~y  with
          |Some(p,_,_,_) -> p
          |None -> failwith "bug" in
    	selection#unselect_all ();
    	selection#select_path path
      )
    end; (* end of optional bit *)

    view_popup_menu treeview ev;
    true (* we handled this *)
  ) else
    false (* we did not handle this *)
