let biblio = ref []
let sort_name = ref false
let sort_album = ref false
let sort_artist = ref true
let sort_genre = ref false

let addBiblio n =
  let fill (song, artist, album, genre, path) =
    let iter = Ettoihc.storeBiblio#append () in
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.songBiblio song;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.artistBiblio artist;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.albumBiblio album;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.genreBiblio genre;
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
  compare name1 name2
  
let sort_by_artist (model:#GTree.model) row1 row2 =
  let name1 = model#get ~row:row1 ~column:Ettoihc.artistBiblio in
  let name2 = model#get ~row:row2 ~column:Ettoihc.artistBiblio in
  compare name1 name2

let sort_by_album (model:#GTree.model) row1 row2 =
  let name1 = model#get ~row:row1 ~column:Ettoihc.albumBiblio in
  let name2 = model#get ~row:row2 ~column:Ettoihc.albumBiblio in
  compare name1 name2

let sort_by_genre (model:#GTree.model) row1 row2 =
  let name1 = model#get ~row:row1 ~column:Ettoihc.genreBiblio in
  let name2 = model#get ~row:row2 ~column:Ettoihc.genreBiblio in
  compare name1 name2

let startBiblio () =
  loadBiblio ();
  let fill (song, artist, album, genre, path) =
    let iter = Ettoihc.storeBiblio#append () in
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.songBiblio song;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.artistBiblio artist;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.albumBiblio album;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.genreBiblio genre;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.pathBiblio path; in
  List.iter fill !biblio;
  Ettoihc.storeBiblio#set_sort_func 0 sort_by_name;
  Ettoihc.storeBiblio#set_sort_func 1 sort_by_artist;
  Ettoihc.storeBiblio#set_sort_func 2 sort_by_album;
  Ettoihc.storeBiblio#set_sort_func 3 sort_by_genre;
  ignore(Ettoihc.colName#connect#clicked (fun () -> 
    if !sort_name then
      Ettoihc.storeBiblio#set_sort_column_id 0 `DESCENDING
    else
      Ettoihc.storeBiblio#set_sort_column_id 0 `ASCENDING;
  sort_name := not !sort_name; sort_artist := false; sort_album := false;
  sort_genre := false));
  ignore(Ettoihc.colArtist#connect#clicked (fun () -> 
    if !sort_artist then
      Ettoihc.storeBiblio#set_sort_column_id 1 `DESCENDING
    else
      Ettoihc.storeBiblio#set_sort_column_id 1 `ASCENDING;
    sort_artist := not !sort_artist; sort_name := false; sort_album := false;
    sort_genre := false));
  ignore(Ettoihc.colAlbum#connect#clicked (fun () -> 
    if !sort_album then
      Ettoihc.storeBiblio#set_sort_column_id 2 `DESCENDING
    else
      Ettoihc.storeBiblio#set_sort_column_id 2 `ASCENDING;
  sort_album := not !sort_album; sort_name := false; sort_artist := false;
  sort_genre := false));
  ignore(Ettoihc.colGenre#connect#clicked (fun () -> 
    if !sort_genre then
      Ettoihc.storeBiblio#set_sort_column_id 3 `DESCENDING
    else
      Ettoihc.storeBiblio#set_sort_column_id 3 `ASCENDING;
  sort_genre := not !sort_genre; sort_name := false; sort_artist := false;
  sort_album := false));
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
