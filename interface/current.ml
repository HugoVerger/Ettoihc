let filepath = ref ""
let indexSong = ref 0
let playList = ref []

let play () =
  let tmp = List.nth !playList !indexSong in
  let tmp2 = match tmp with (_,_,a) -> a in
  if (List.length !playList != 0 && 
  	(!Ettoihc.pause || (!filepath != tmp2))) then
      filepath := tmp2
      
let launchPlaylist () =
  Ettoihc.openDialog filepath;
  if (Ettoihc.get_extension !filepath) then
    Playlist.addSong !filepath playList
  else
    begin
      Playlist.cleanPlaylist playList indexSong;
      Wrap.stop_sound();
      Playlist.addPlaylist !filepath playList
    end;
    
    (*(* Column #1: song *)
    let col = GTree.view_column ~title:"Song"
      ~renderer:(GTree.cell_renderer_text [], ["text", Ettoihc.songPlaylist]) () in
    ignore (Ettoihc.playlistView#append_column col);

    (* Column #2: artist *)
    let col = GTree.view_column ~title:"Artist"
      ~renderer:(GTree.cell_renderer_text [], ["text", Ettoihc.artistPlaylist]) () in
    ignore (Ettoihc.playlistView#append_column col);*)
