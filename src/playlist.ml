let addSong filepath playList =
  let rec checkExist = function
    |[] -> false
    |(_,_,file)::_ when file = filepath -> true
    |(_,_,_)::t -> checkExist t in
  let tmp = checkExist !playList in
    if tmp then () else
      begin
        let artist = ref "" and song = ref "" in
        if Meta.Id3v1.has_tag filepath then
          begin
            let t = Meta.Id3v1.read_file filepath in
            artist := Meta.Id3v1.getArtist t;
            song := Meta.Id3v1.getTitle t;
          end;
        playList := !playList @ [(!song,!artist,filepath)];
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
