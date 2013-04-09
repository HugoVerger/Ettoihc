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
