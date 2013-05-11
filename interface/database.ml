let biblio = ref []
let sort_name = ref false
let sort_artist = ref true

let addBiblio n =
  let fill (song, artist, path) =
    let iter = Ettoihc.storeBiblio#append () in
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.songBiblio song;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.artistBiblio artist;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.pathBiblio path; in
  fill (List.nth !biblio n)

let checkBiblio () =
  let filepath = !Current.filepath in
  if (Ettoihc.get_extension filepath) then
    begin
      Biblio.addSong filepath biblio;
      addBiblio (List.length !biblio - 1)
    end
  else
    begin
      Biblio.addPlaylist filepath biblio
    end

let loadBiblio () =
  let ic = open_in "biblio" in
  try
    while true; do
      Biblio.addSong (input_line ic) biblio;
    done;
  with End_of_file ->
    close_in ic

let compare a b =
    if a < b then -1
    else if a > b then 1
    else 0

let sort_by_name (model:#GTree.model) row1 row2 =
  let name1 = model#get ~row:row1 ~column:Ettoihc.songBiblio in
  let name2 = model#get ~row:row2 ~column:Ettoihc.songBiblio in
  sort_name := not !sort_name; sort_artist := false;
  compare name1 name2
  
let sort_by_artist (model:#GTree.model) row1 row2 =
  let name1 = model#get ~row:row1 ~column:Ettoihc.artistBiblio in
  let name2 = model#get ~row:row2 ~column:Ettoihc.artistBiblio in
  sort_artist := not !sort_artist; sort_name := false;
  compare name1 name2

let startBiblio () =
  loadBiblio ();
  let fill (song, artist, path) =
    let iter = Ettoihc.storeBiblio#append () in
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.songBiblio song;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.artistBiblio artist;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.pathBiblio path; in
  List.iter fill !biblio;
  Ettoihc.storeBiblio#set_sort_func 0 sort_by_name;
  Ettoihc.storeBiblio#set_sort_func 1 sort_by_artist;
  ignore(Ettoihc.colName#connect#clicked (fun () -> 
    if !sort_name then
      Ettoihc.storeBiblio#set_sort_column_id 0 `DESCENDING
    else
      Ettoihc.storeBiblio#set_sort_column_id 0 `ASCENDING));
  ignore(Ettoihc.colArtist#connect#clicked (fun () -> 
    if !sort_artist then
      Ettoihc.storeBiblio#set_sort_column_id 1 `DESCENDING
    else
      Ettoihc.storeBiblio#set_sort_column_id 1 `ASCENDING));
  Ettoihc.storeBiblio#set_sort_column_id 1 `ASCENDING

let on_row_activated (view:GTree.view) path column =
  let model = view#model in
  let row = model#get_iter path in
  let pathFile = model#get ~row ~column:Ettoihc.pathBiblio in
  Current.filepath := pathFile;
  if not (Playlist.addSong pathFile) then
    begin
      Current.indexSong := !Playlist.nbSong - 1;
      Current.play();
      !Ettoihc.play ()
    end
