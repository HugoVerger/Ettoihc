(** Playlist manipulations **)

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
  |n when n = !UiPage1.nbSong -> false
  |n ->
    begin
      let iter = UiPage1.store#iter_children ~nth:n None in
      let test = UiPage1.store#get ~row:iter ~column:UiPage1.path in
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
        let iter = UiPage1.store#append () in
        UiPage1.nbSong := !UiPage1.nbSong + 1;
        UiPage1.store#set ~row:iter ~column:UiPage1.nmb !UiPage1.nbSong;
        UiPage1.store#set ~row:iter ~column:UiPage1.random !UiPage1.nbSong;
        UiPage1.store#set ~row:iter ~column:UiPage1.title
          (Meta.giveInfo ["TIT2"] t);
        UiPage1.store#set ~row:iter ~column:UiPage1.artist 
          (Meta.giveInfo ["TPE1"; "TPE2"] t);
        UiPage1.store#set ~row:iter ~column:UiPage1.path file;
        Header.indexSong := !UiPage1.nbSong;
        Header.pause := true;
        Header.play ()
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


(** Sorting of columns **)

let connectSort () =
  let compare a b =
    if a < b then -1
    else if a > b then 1
    else 0 in

  let sort_by col (model:#GTree.model) row1 row2 =
    let name1 = model#get ~row: row1 ~column: col in
    let name2 = model#get ~row: row2 ~column: col in
    compare name1 name2 in

  UiPage1.store#set_sort_func 0 (sort_by UiPage1.nmb);
  UiPage1.store#set_sort_func 1 (sort_by UiPage1.random)


(** Handling mouse control **)

let doubleClickLeft (view:GTree.view) path column =
  let model = view#model in
  let row = model#get_iter path in
  let nmb = ref 0 in

  if (!Header.random) then
    nmb := model#get ~row ~column: UiPage1.random
  else
    nmb := model#get ~row ~column: UiPage1.nmb;
  Header.pause := true;
  Header.indexSong := !nmb;
  Header.play ()

let rec actNmb = function
  |n when n > !UiPage1.nbSong -> ()
  |n ->
    let iter = UiPage1.store#iter_children ~nth:(n - 1) None in
    UiPage1.store#set ~row:iter ~column: UiPage1.nmb (n - 1);
    UiPage1.store#set ~row:iter ~column: UiPage1.random (n - 1);
    actNmb (n+1)

let changeOrder path limit add =
  let row = UiPage1.store#get_iter path in

  let nmb = ref 0 in
  if (!Header.random) then
    nmb := UiPage1.store#get ~row ~column: UiPage1.random
  else
    nmb := UiPage1.store#get ~row ~column: UiPage1.nmb;

  if not (limit = !nmb) then
    begin
      let iter = ref row in
      if add > 0 then
        iter := UiPage1.store#iter_children ~nth: (!nmb) None
      else
        iter := UiPage1.store#iter_children ~nth: (!nmb - 2) None;

      if !Header.indexSong = !nmb + add then
        Header.indexSong := !nmb
      else if !Header.indexSong = !nmb then
        Header.indexSong := !nmb + add;

      if (!Header.random) then
        begin
          UiPage1.store#set ~row: row ~column: UiPage1.random (!nmb + add);
          UiPage1.store#set ~row: !iter ~column:UiPage1.random (!nmb);
          UiPage1.store#set_sort_column_id 1 `ASCENDING
        end
      else
        begin
          UiPage1.store#set ~row: row ~column: UiPage1.nmb (!nmb + add);
          UiPage1.store#set ~row: !iter ~column: UiPage1.nmb (!nmb);
          UiPage1.store#set_sort_column_id 0 `ASCENDING
        end
    end


let removeSong p =
  let row = UiPage1.store#get_iter p in
  let n = ref 0 in
  if (!Header.random) then
      n := UiPage1.store#get ~row ~column: UiPage1.random
  else
      n := UiPage1.store#get ~row ~column: UiPage1.nmb;
  if (!Header.indexSong = !n) then
    Header.stop ();
  actNmb (!n + 1);
  ignore(UiPage1.store#remove row);
  UiPage1.nbSong := !UiPage1.nbSong - 1

let clearPlaylist () =
  UiPage1.store#clear ();
  Header.stop ()

let popupMenu treeview ev p =
  let menu = UiPage1.popup () in
  let items = menu#children in

  ignore((List.nth items 0)#connect#activate 
    ~callback:(fun () -> changeOrder p 1 (-1)));

  ignore((List.nth items 1)#connect#activate 
    ~callback:(fun () -> changeOrder p !UiPage1.nbSong 1));

  ignore((List.nth items 2)#connect#activate 
    ~callback:(fun () -> removeSong p));

  ignore((List.nth items 3)#connect#activate 
    ~callback:(fun () -> clearPlaylist ()));

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
  ignore(UiPage1.view#connect#row_activated
            ~callback: (doubleClickLeft UiPage1.view));
  ignore(UiPage1.view#event#connect#button_press
            ~callback: (clickRight UiPage1.view))
