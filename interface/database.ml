let biblio = ref []

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

let startBiblio () =
  loadBiblio ();
  let fill (song, artist, path) =
    let iter = Ettoihc.storeBiblio#append () in
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.songBiblio song;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.artistBiblio artist;
    Ettoihc.storeBiblio#set ~row:iter ~column:Ettoihc.pathBiblio path; in
  List.iter fill !biblio

let on_row_activated (view:GTree.view) path column =
  let model = view#model in
  let row = model#get_iter path in
  let pathFile = model#get ~row ~column:Ettoihc.pathBiblio in
  Current.filepath := pathFile;
  if not (Playlist.addSong pathFile Current.playList) then
    begin
      let playList = !Current.playList in
      Current.fill (List.nth playList ((List.length playList) -1));
      Current.indexSong := (List.length playList) - 1;
      Current.play();
      !Ettoihc.play ()
    end
