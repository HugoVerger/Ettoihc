let sort_name = ref false
let sort_album = ref true
let sort_artist = ref false
let sort_genre = ref false

(** Library manipulations **)

let ext wanted s =
  if String.length s > 4 then
    begin
      let ext = String.sub s ((String.length s) - 4) 4 in
      match ext with
        |s when s = wanted -> true
        |_ -> false
    end
  else
    false

let rec checkExist file = function
  |n when n = !UiPage2.nbSong -> false
  |n ->
    begin
      let iter = UiPage2.store#iter_children ~nth:n None in
      let test = UiPage2.store#get ~row:iter ~column:UiPage2.path in
        if (test = file) then
          true
        else
          checkExist file (n + 1)
    end

let rec add file =
  try
    if (Sys.file_exists file ) && (Sys.is_directory file) then
      Array.iter (fun a -> add (file ^ "/" ^ a)) (Sys.readdir file)
    else if Sys.file_exists file 
         && ext ".mp3" file 
         && not(checkExist file 0) then
      begin
        let t = Meta.read file in
        let iter = UiPage2.store#append () in
        UiPage2.nbSong := !UiPage2.nbSong + 1;
        UiPage2.store#set ~row:iter 
          ~column:UiPage2.title (Meta.giveInfo ["TIT2"] t);
        UiPage2.store#set ~row:iter
          ~column:UiPage2.artist (Meta.giveInfo ["TPE1"; "TPE2"] t);
        UiPage2.store#set ~row:iter
          ~column:UiPage2.album (Meta.giveInfo ["TALB"] t);
        UiPage2.store#set ~row:iter 
          ~column:UiPage2.genre ((Meta.giveInfo ["TCON"] t));
        UiPage2.store#set ~row:iter ~column:UiPage2.path file
      end
    else if (Sys.file_exists file ) && (ext ".m3u" file) then
      begin
        let ic = open_in file in
        try
        while true do
          add (input_line ic)
        done;
        with End_of_file ->
          close_in ic
      end
  with Sys_error e -> () (* Catch Protected Files *)

let loadBiblio () =
  let ic = open_in "bin/biblio" in
  try
    while true; do
      add (input_line ic)
    done;
  with End_of_file ->
    close_in ic

let saveBiblio () =
  let oc = open_out "bin/biblio" in
  let store = UiPage2.store in
  let first = store#get_iter_first in
  begin
    match first with
    |Some iter ->
      Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:UiPage2.path);

      while store#iter_next iter do
        Printf.fprintf oc "%s\n"(store#get ~row:iter ~column:UiPage2.path)
      done
    |None -> ()
  end;
  close_out oc

(** Sorting of columns **)

let compare a b =
  if a < b then -1
  else if a > b then 1
  else 0

let sort_by col (model:#GTree.model) row1 row2 =
  let name1 = model#get ~row:row1 ~column:col in
  let name2 = model#get ~row:row2 ~column:col in
  compare name1 name2

let connectSort () =
  UiPage2.store#set_sort_func 0 (sort_by UiPage2.title);
  UiPage2.store#set_sort_func 1 (sort_by UiPage2.artist);
  UiPage2.store#set_sort_func 2 (sort_by UiPage2.album);
  UiPage2.store#set_sort_func 3 (sort_by UiPage2.genre);

  ignore(UiPage2.colName#connect#clicked (fun () -> 
    if !sort_name then
      UiPage2.store#set_sort_column_id 0 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 0 `ASCENDING;
    sort_name := not !sort_name; sort_artist := false; sort_album := false;
    sort_genre := false));

  ignore(UiPage2.colArtist#connect#clicked (fun () -> 
    if !sort_artist then
      UiPage2.store#set_sort_column_id 1 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 1 `ASCENDING;
    sort_artist := not !sort_artist; sort_name := false; sort_album := false;
    sort_genre := false));

  ignore(UiPage2.colAlbum#connect#clicked (fun () -> 
    if !sort_album then
      UiPage2.store#set_sort_column_id 2 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 2 `ASCENDING;
  sort_album := not !sort_album; sort_name := false; sort_artist := false;
  sort_genre := false));

  ignore(UiPage2.colGenre#connect#clicked (fun () -> 
    if !sort_genre then
      UiPage2.store#set_sort_column_id 3 `DESCENDING
    else
      UiPage2.store#set_sort_column_id 3 `ASCENDING;
  sort_genre := not !sort_genre; sort_name := false; sort_artist := false;
  sort_album := false));

  UiPage2.store#set_sort_column_id 2 `ASCENDING

(** Handling Mouse Control **)

let removeSong p =
  let row = UiPage2.store#get_iter p in
  ignore(UiPage2.store#remove row);
  UiPage2.nbSong := !UiPage2.nbSong - 1

let doubleClickLeft (view:GTree.view) path column =
  let str_op = function
    |Some x -> x
    |_ -> failwith "Need a file" in

  let model = view#model in
  let row = model#get_iter path in
  let file = model#get ~row ~column:UiPage2.path in

  if (Sys.file_exists file) then
    Playlist.add file
  else
    begin
      let prob = Ui.missing () in
      if (prob#run ()) = `OK then
        begin
          let dlg = Ui.search () in
          if (dlg#run ()) = `OK then
            begin
              let file = str_op(dlg#filename) in
              removeSong path;
              Playlist.add file
            end;
          dlg#destroy ()
        end;
      prob#destroy ()
    end

let editTag file =
  let dlg = (Ui.tag ()) in

  let t = Meta.read file in

  (List.nth !Ui.tagViewList 0)#buffer#set_text (Meta.giveInfo ["TRCK"] t);
  (List.nth !Ui.tagViewList 1)#buffer#set_text (Meta.giveInfo ["TIT2"] t);
  (List.nth !Ui.tagViewList 2)#buffer#set_text 
    (Meta.giveInfo ["TPE1"; "TPE2"] t);
  (List.nth !Ui.tagViewList 3)#buffer#set_text (Meta.giveInfo ["TALB"] t);
  (List.nth !Ui.tagViewList 4)#buffer#set_text (Meta.giveInfo ["TDOR"] t);
  (List.nth !Ui.tagViewList 5)#buffer#set_text (Meta.giveInfo ["TCON"] t);

  if ((dlg#run ()) = `SAVE) then
    begin
      Meta.write file 
       [("TRCK",(List.nth !Ui.tagViewList 0)#buffer#get_text ());
        ("TIT2",(List.nth !Ui.tagViewList 1)#buffer#get_text ());
        ("TPE1",(List.nth !Ui.tagViewList 2)#buffer#get_text ());
        ("TALB",(List.nth !Ui.tagViewList 3)#buffer#get_text ());
        ("TYER",(List.nth !Ui.tagViewList 4)#buffer#get_text ());
        ("TCON",(List.nth !Ui.tagViewList 5)#buffer#get_text ())]
    end;
  dlg#destroy ()

let popupMenu treeview ev p =
  let menu = UiPage2.popup () in
  let items = menu#children in

  ignore((List.nth items 0)#connect#activate 
    ~callback:(fun () -> removeSong p));

  ignore((List.nth items 1)#connect#activate ~callback:(fun () ->
    let row = UiPage2.store#get_iter p in
    let file = UiPage2.store#get ~row ~column:UiPage2.path in
    editTag file;
    removeSong p;
    add file));

  menu#popup
    ~button:(GdkEvent.Button.button ev)
    ~time:(GdkEvent.Button.time ev)

let clickRight treeview ev =
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
                popupMenu treeview ev p;
              end
            |None -> ()
        end;
      true
    end
  else
    false

let connectUI () =
  ignore(UiPage2.view#connect#row_activated
            ~callback: (doubleClickLeft UiPage2.view));
  ignore(UiPage2.view#event#connect#button_press
            ~callback: (clickRight UiPage2.view))
