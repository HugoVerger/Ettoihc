let addSong filepath playList =
  let rec checkExist = function
    |[] -> false
    |(_,_,file)::_ when file = filepath -> true
    |(_,_,_)::t -> checkExist t in
  let tmp = checkExist !playList in
    if tmp then () else
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
        playList := !playList @ [(!title,!artist,filepath)];
    end;
  tmp

let getFile nmb playList =
  let tmp = List.nth playList nmb in
  let tmp2 = match tmp with (_,_,a) -> a in
  tmp2

let cleanPlaylist playList indexSong =
  playList := [];
  indexSong := 0;
  Ettoihc.playListForSave := "";
  Ettoihc.pause := true

let addPlaylist filepath playList =
  let ic = open_in filepath in
  try
    while true; do
      ignore(addSong (input_line ic) playList);
    done;
  with End_of_file ->
    close_in ic
