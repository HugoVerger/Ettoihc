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
        let t = Meta.v1_of_v2 (Meta.read_both_as_v2 file) in
        let iter = UiPage1.store#append () in
        UiPage1.nbSong := !UiPage1.nbSong + 1;
        UiPage1.store#set ~row:iter ~column:UiPage1.nmb !UiPage1.nbSong;
        UiPage1.store#set ~row:iter ~column:UiPage1.random !UiPage1.nbSong;
        UiPage1.store#set ~row:iter ~column:UiPage1.title t.Meta.Id3v1.title;
        UiPage1.store#set ~row:iter ~column:UiPage1.artist t.Meta.Id3v1.artist;
        UiPage1.store#set ~row:iter ~column:UiPage1.path file;
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
