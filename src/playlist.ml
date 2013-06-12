(*let nbSong = ref 0

let addSong filepath =
  let rec checkExist n =
    if (n >= !nbSong) then
      false
    else
      begin
        let iter = Ettoihc.storePlaylist#iter_children ~nth:n None in
        let file = (Ettoihc.storePlaylist#get ~row:iter 
                                              ~column:Ettoihc.pathPlaylist) in
        if (filepath = file) then
          true
        else
          checkExist (n + 1)
      end in
  let tmp = (checkExist 0) in
  if not tmp then
    begin
      let title = ref "" and album = ref "" and year = ref "" in
      let comment = ref "" and genre = ref "" and artist = ref "" in
      let tracknum = ref "" in
      if Meta.Id3v1.has_tag filepath then
        begin
          let t = Meta.v1_of_v2 (Meta.read_both_as_v2 filepath) in
          title := t.Meta.Id3v1.title ;
          artist := t.Meta.Id3v1.artist ;
          album := t.Meta.Id3v1.album ;
          year := t.Meta.Id3v1.year ;
          comment := t.Meta.Id3v1.comment ;
          tracknum := (string_of_int(t.Meta.Id3v1.tracknum));
          genre := (string_of_int(t.Meta.Id3v1.genre));
        end;
      nbSong := !nbSong + 1;
      let iter = Ettoihc.storePlaylist#append () in
      Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.nmbPlaylist !nbSong;
      Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.songPlaylist !title;
      Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.artistPlaylist !artist;
      Ettoihc.storePlaylist#set ~row:iter ~column:Ettoihc.pathPlaylist filepath;
      Ettoihc.playListForSave := !Ettoihc.playListForSave ^ filepath ^ "\n"
    end;
  tmp*)

let cleanPlaylist indexSong =
  nbSong := 0;
  indexSong := 0;
  Ettoihc.playListForSave := "";
  Ettoihc.pause := true

(*let addPlaylist filepath =
  let ic = open_in filepath in
  try
    while true; do
      ignore(addSong (input_line ic));
    done;
  with End_of_file ->
    close_in ic*)
